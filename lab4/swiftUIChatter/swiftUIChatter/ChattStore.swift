//
//  ChattStore.swift
//  swiftChatter
//
//  Created by Trevor Judice on 9/14/21.
//
import Foundation

final class ChattStore: ObservableObject  {
    static let shared = ChattStore()
    private init() {}
    var chatts = [Chatt]()
    private let nFields = Mirror(reflecting: Chatt()).children.count
    private let serverUrl = "https://18.224.108.161/"
    
    func postChatt(_ chatt: Chatt) async {
            let jsonObj = ["chatterID": ChatterID.shared.id,
                           "message": chatt.message]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
                print("postChatt: jsonData serialization error")
                return
            }
                    
            guard let apiUrl = URL(string: serverUrl+"postauth/") else {
                print("postauth: Bad URL")
                return
            }
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "POST"
            request.httpBody = jsonData

        do {
                    let (_, response) = try await URLSession.shared.data(for: request)

                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("postChatt: HTTP STATUS: \(httpStatus.statusCode)")
                        return
                    }
                } catch {
                    print("postChatt: NETWORKING ERROR")
                }
    }
    
    @MainActor
    func getChatts() async {
        guard let apiUrl = URL(string: serverUrl+"getchatts/") else {
            print("getChatts: Bad URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"

        do {
                    let (data, response) = try await URLSession.shared.data(for: request)
                        
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
                            self.chatts.append(Chatt(username: chattEntry[0],
                                                     message: chattEntry[1],
                                                     timestamp: chattEntry[2]))
                        } else {
                            print("getChatts: Received unexpected number of fields: \(chattEntry.count) instead of \(self.nFields).")
                        }
                    }
                } catch {
                    print("getChatts: NETWORKING ERROR")
        }
    }
    func addUser(_ idToken: String?) async -> Bool {
        guard let idToken = idToken else {
            return false
        }
        
        let jsonObj = ["clientID": "751671678720-n3t27a1rml3mr9a7u9tdflbnac9n5e53.apps.googleusercontent.com",
                    "idToken" : idToken]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            print("addUser: jsonData serialization error")
            return false
        }

        guard let apiUrl = URL(string: serverUrl+"adduser/") else {
            print("addUser: Bad URL")
            return false
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("addUser: HTTP STATUS: \(httpStatus.statusCode)")
                return false
            }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("addUser: failed JSON deserialization")
                return false
            }

            ChatterID.shared.id = jsonObj["chatterID"] as? String
            ChatterID.shared.expiration = Date()+(jsonObj["lifetime"] as! TimeInterval)
            
            guard let _ = ChatterID.shared.id else {
                return false
            }
            ChatterID.shared.save()
            return true
        } catch {
            print("addUser: NETWORKING ERROR")
        }
        return false
    }
    
}
