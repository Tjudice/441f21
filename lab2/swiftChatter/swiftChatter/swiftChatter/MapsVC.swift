//
//  MapsVC.swift
//  swiftChatter
//
//  Created by Trevor Judice on 10/12/21.
//

import UIKit
import GoogleMaps

final class MapsVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    private var mapView: GMSMapView!
    var locmanager: CLLocationManager!

    var chatt: Chatt? = nil

    override func loadView() {
        mapView = GMSMapView()
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // put mylocation marker down; Google automatically asks for location permission
        mapView.isMyLocationEnabled = true
        // enable the location bull's eye button
        mapView.settings.myLocationButton = true
        var chattMarker: GMSMarker!

                if let chatt = chatt, let geodata = chatt.geodata {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon)
                    chattMarker = GMSMarker(position: coordinate)
                    chattMarker.map = mapView
                    chattMarker.userData = chatt

                    // move camera to chatt's location
                    mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 16.0)
                } else {
                            // set self as the delegate for CLLocationManager's events
                            // and set up the location manager.
                            locmanager.delegate = self

                            // obtain user's current location so that we can
                            // zoom the map to the current location
                            locmanager.startUpdatingLocation()
                            
                            // Add a marker on the MapView for each chatt
                            ChattStore.shared.chatts.forEach {
                                if let geodata = $0.geodata {
                                    chattMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: geodata.lat, longitude: geodata.lon))
                                    chattMarker.map = mapView
                                    chattMarker.userData = $0
                                }
                            }
                        }
                    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = mapView.myLocation else {
            return
        }

        // Zoom in to the user's current location
        mapView.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16.0)

        manager.stopUpdatingLocation()
    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        guard let chatt = marker.userData as? Chatt else {
            return nil
        }
        
        let infoView = UIView(frame: CGRect.init(x: 0, y: 0, width: 300, height: 150))
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = UIColor.white
        infoView.layer.cornerRadius = 6
        
        let timestamp = UILabel(frame: CGRect.init(x: 10, y: 10, width: view.frame.size.width - 16, height: 15))
        timestamp.translatesAutoresizingMaskIntoConstraints = false
        timestamp.text = chatt.timestamp
        timestamp.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        timestamp.textColor = .systemBlue
        
        let username = UILabel(frame: CGRect.init(x: timestamp.frame.origin.x, y: timestamp.frame.origin.y + timestamp.frame.size.height + 5, width: view.frame.size.width - 16, height: 15))
        username.translatesAutoresizingMaskIntoConstraints = false
        username.text = chatt.username
        username.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        username.textColor = .black
        
        let message = UILabel(frame: CGRect.init(x: username.frame.origin.x, y: username.frame.origin.y + username.frame.size.height + 10, width: view.frame.size.width - 16, height: 15))
        message.translatesAutoresizingMaskIntoConstraints = false
        message.text = chatt.message
        message.textColor = .darkGray

        infoView.addSubview(timestamp)
        infoView.addSubview(username)
        infoView.addSubview(message)

        guard let geodata = chatt.geodata else {
            return infoView
        }
        
        let infoLabel = UILabel(frame: CGRect.init(x: message.frame.origin.x, y: message.frame.origin.y + message.frame.size.height + 30, width: view.frame.size.width - 16, height: 40))
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.systemFont(ofSize: 16)
        infoLabel.numberOfLines = 2
        infoLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        infoLabel.textColor = .black
        infoLabel.text = "Posted from " + geodata.loc + ", while facing " + geodata.facing + " moving at " + geodata.speed + " speed."
        infoLabel.highlight(searchedText: geodata.loc, geodata.facing, geodata.speed)
        
        infoView.addSubview(infoLabel)
        
        return infoView
    }
}
