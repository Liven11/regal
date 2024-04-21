//
//  ContentView.swift
//  Regal
//
//  Created by Liven on 21/04/24.
//
import SwiftUI
import CoreLocation
import UserNotifications

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    var lastNotificationTime: Date?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        UNUserNotificationCenter.current().delegate = self
    }

    func startMonitoring() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        checkPredefinedRegions(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func checkPredefinedRegions(for location: CLLocation) {
        let regions: [CLCircularRegion: String] = [
            CLCircularRegion(center: CLLocationCoordinate2D(latitude: 28.6315, longitude: 77.2167), radius: 250, identifier: "ConnaughtPlace"): "You are in Connaught Place",
            CLCircularRegion(center: CLLocationCoordinate2D(latitude: 28.638224, longitude: 77.275359), radius: 250, identifier: "LaxmiNagar"): "You are in Laxmi Nagar"
        ]
        for (region, message) in regions {
            if region.contains(location.coordinate) {
                if let lastNotificationTime = lastNotificationTime, Date().timeIntervalSince(lastNotificationTime) < 10 {
                    return
                }
                sendNotification(message: message)
                break
            }
        }
    }

    func sendNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Location Alert"
        content.body = message
        let notificationIdentifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
        lastNotificationTime = Date()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}

struct ContentView: View {
    @ObservedObject var locationDelegate = LocationDelegate()

    var body: some View {
        VStack {
            Text(locationMessage)
                .font(.title)
                .foregroundColor(.white)
            
            if let userLocation = locationDelegate.currentLocation {
                Text("Latitude: \(userLocation.coordinate.latitude)")
                Text("Longitude: \(userLocation.coordinate.longitude)")
            } else {
                Text("Latitude: -")
                Text("Longitude: -")
            }
        }
        .padding()
        .background(Color.gray)
        .cornerRadius(10)
        .onAppear {
            locationDelegate.startMonitoring()
        }
    }

    var locationMessage: String {
        guard let userLocation = locationDelegate.currentLocation else {
            return "Your location Is"
        }
        
        let regions: [CLCircularRegion: String] = [
            CLCircularRegion(center: CLLocationCoordinate2D(latitude: 28.633261947368027, longitude: 77.21708916441978), radius: 250, identifier: "Regal Building"): "You are Near Regal Building ",
            CLCircularRegion(center: CLLocationCoordinate2D(latitude: 28.638224, longitude: 77.275359), radius: 250, identifier: "LaxmiNagar"): "You are in Laxmi Nagar"
        ]
        for (region, message) in regions {
            if region.contains(userLocation.coordinate) {
                return message
            }
        }
        return "You are not in a predefined region"
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
