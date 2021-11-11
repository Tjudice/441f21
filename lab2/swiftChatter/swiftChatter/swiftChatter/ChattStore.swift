//
//  ChattStore.swift
//  swiftChatter
//
//  Created by Trevor Judice on 9/14/21.
//

import Foundation

final class ChattStore {
    static let shared = ChattStore()
    private init() {}
    var chatts = [Chatt]()
    private let nFields = Mirror(reflecting: Chatt()).children.count
    private let serverUrl = "https://18.224.108.161/"
    
    func postChatt(_ chatt: Chatt) {
        var geoObj: Data?
        if let geodata = chatt.geodata {
            geoObj = try? JSONSerialization.data(withJSONObject: [geodata.lat, geodata.lon, geodata.loc, geodata.facing, geodata.speed])
        }
        let jsonObj = ["username": chatt.username,
                               "message": chatt.message,
                               "geodata": (geoObj == nil) ? nil : String(data: geoObj!, encoding: .utf8)]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("postChatt: jsonData serialization error")
            return
        }
                
        guard let apiUrl = URL(string: serverUrl+"postmaps/") else {
            print("postChatt: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("postChatt: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("postChatt: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
        }.resume()
    }
    
    func getChatts(_ completion: ((Bool) -> ())?) {
        guard let apiUrl = URL(string: serverUrl+"getmaps/") else {
            print("getChatts: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            var success = false
            defer { completion?(success) }
            
            guard let data = data, error == nil else {
                print("getChatts: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getChatts: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getChatts: failed JSON deserialization")
                return
            }
            let chattsReceived = jsonObj["chatts"] as? [[String?]] ?? []
            self.chatts = [Chatt]()
            for chattEntry in chattsReceived {
                if chattEntry.count == self.nFields {
                    let geoArr = chattEntry[3]?.data(using: .utf8).flatMap {
                                            try? JSONSerialization.jsonObject(with: $0) as? [Any]
                                        }
                                        self.chatts.append(Chatt(username: chattEntry[0],
                                                                 message: chattEntry[1],
                                                                 timestamp: chattEntry[2],
                                                                 geodata: geoArr.map {
                                                                    GeoData(lat: $0[0] as! Double,
                                                                            lon: $0[1] as! Double,
                                                                            loc: $0[2] as! String,
                                                                            facing: $0[3] as! String,
                                                                            speed: $0[4] as! String)
                                                                 }
                                        ))
                } else {
                    print("getChatts: Received unexpected number of fields: \(chattEntry.count) instead of \(self.nFields).")
                }
            }
            success = true // for completion(success)
        }.resume()
    }
    
}
