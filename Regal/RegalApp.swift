//  RegalApp.swift

import SwiftUI
import CoreLocation
import UserNotifications

@main
struct RegalApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    var locationManager: CLLocationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Request location authorization
               locationManager = CLLocationManager()
               locationManager?.requestWhenInUseAuthorization()

               // Request notification authorization
               UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                   if granted {
                       print("Notification permission granted")
                   } else {
                       print("Notification permission denied")
                   }
               }

               return true
           }
       }
