import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      print("Location update: \(location)")

      let latitude = location.coordinate.latitude
      let longitude = location.coordinate.longitude

      postUpdate(latitude, longitude)
    }
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if (status == .authorizedWhenInUse) {
      print("Starting location updates...")
      manager.startUpdatingLocation()
    }
    else {
      print("Error: unauthorized to get location data...")
    }
  }

  func postUpdate(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {

    let getURL = URL(string: "https://api.bestwebsiteofalltime.com")!

    var request = URLRequest(url: getURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    let parameters = ["latitude": latitude, "longitude": longitude]
    do {
      let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options: [])
      request.httpBody = jsonParams
    }
    catch {
      print("Error: unable to add parameters to POST request.")
      return
    }

    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
      if let error = error {
        print("GET Request: Communication error: \(error)")
        return
      }

      guard let data = data else {
        print("Received empty response.")
        return
      }

      do {
        let resultObject = try JSONSerialization.jsonObject(with: data, options: [])
        print("Echo from API: \(resultObject)")
      }
      catch {
        let responseString = String(data: data, encoding: .utf8)
        print("Unable to parse response: \(responseString!)")
      }
    }).resume()
  }
}

