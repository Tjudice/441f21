//
//  ViewController.swift
//  swiftChatter
//
//  Created by Trevor Judice on 9/14/21.
//

import UIKit
import GoogleMaps

final class PostVC: UIViewController, CLLocationManagerDelegate {
    
    private var usernameLabel: UILabel!
    private var messageTextView: UITextView!
    
    var locmanager: CLLocationManager!
    private var lat = 0.0
    private var lon = 0.0
    private var speed = -1.0
    private var heading = 0.0
    private var geodata: GeoData!
    
    override func loadView() {
        let postView = PostView()
        usernameLabel = postView.usernameLabel
        messageTextView = postView.messageTextView
        view = postView
        let submitButton = UIBarButtonItem(
                    image: UIImage(systemName: "paperplane"),
                    primaryAction:UIAction(handler: submitChatt))
        self.navigationItem.rightBarButtonItem = submitButton
        self.navigationItem.title = "Post"
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        locmanager.delegate = self
        locmanager.startUpdatingLocation()
        locmanager.startUpdatingHeading()
    }
    
    func submitChatt(_ sender: Any) {
            geodata = GeoData(lat: lat, lon: lon, facing: convertHeading(), speed: convertSpeed())
            convertLocation {
                ChattStore.shared.postChatt(Chatt(username: self.usernameLabel.text,
                                                  message: self.messageTextView.text,
                                                  geodata: self.geodata))
            
            }
            dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                // Get user's location
                lat = location.coordinate.latitude
                lon = location.coordinate.longitude
                speed = location.speed
            }
        }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.magneticHeading
    }
    
    func convertHeading() -> String {
        let compass = ["North", "NE", "East", "SE", "South", "SW", "West", "NW", "North"]
        let index = Int(round(heading.truncatingRemainder(dividingBy: 360) / 45))
        return compass[index]
    }
    func convertSpeed() -> String {
        switch speed {
            case 1.2..<5:
                return "walking"
            case 5..<7:
                return "running"
            case 7..<13:
                return "cycling"
            case 13..<90:
                return "driving"
            case 90..<139:
                return "in train"
            case 139..<225:
                return "flying"
            default:
                return "resting"
        }
    }
    func convertLocation(_ completion: @escaping () -> ()) {
        // Reverse geocode to get user's city name
        GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lon)) { response, _ in
            if let address = response?.firstResult(), let lines = address.lines {
                // get city name from the first address returned
                self.geodata.loc = lines[0].components(separatedBy: ", ")[1]
            }
            completion()
        }
    }
    override func viewWillDisappear(_ anim: Bool) {
        super.viewWillDisappear(anim)
        
        locmanager.stopUpdatingLocation()
        locmanager.stopUpdatingHeading()
    }
}

