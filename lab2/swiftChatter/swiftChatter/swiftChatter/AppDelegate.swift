//
//  AppDelegate.swift
//  swiftChatter
//
//  Created by Trevor Judice on 9/14/21.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyB8tmgwdnsQyoIaSi016u6PtJlGWbpYQ7A")

           
        window = UIWindow()
        if let window = window {
            // UIWindow is a reference type
            window.rootViewController = UINavigationController(rootViewController: MainVC())
            window.makeKeyAndVisible()
        }
        return true
    }
}

