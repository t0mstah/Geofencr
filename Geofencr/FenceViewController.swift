//
//  FenceViewController.swift
//  Geofencr
//
//  Created by Tommy Fang on 3/12/17.
//
//

import UIKit
import MapKit
import CoreLocation

class FenceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    var topMargin: CGFloat!
    var passedValue: String!
    var dayValue: UILabel!
    var weekValue: UILabel!
    var monthValue: UILabel!
    
    var locationManager : CLLocationManager!
    var mapView : MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topMargin = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.size.height
        self.title = passedValue!
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Novecentosanswide-Medium", size: 17.0)!], for: .normal)
        
        mapView = MKMapView()
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10.0
            locationManager.startUpdatingLocation()
        }
     
        _ = addLabel("average visits", 0.0, 20.0, "Novecentosanswide-Medium", 12.0, UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0))
        _ = addLabel("last visit", 0.0, 150.0, "Novecentosanswide-Medium", 12.0, UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0))
        
        dayValue = addLabel("00.0", -(view.frame.size.width / 4.0), 70.0, "SourceSansPro-Semibold", 32.0, UIColor(red:0.11, green:0.11, blue: 0.11, alpha:1.0))
        _ = addLabel("1D", -(view.frame.size.width / 4.0), 100.0, "SourceSansPro-Regular", 12.0, UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0))
        weekValue = addLabel("0.0", 0.0, 70.0, "SourceSansPro-Semibold", 32.0, UIColor(red:0.11, green:0.11, blue: 0.11, alpha:1.0))
        _ = addLabel("1W", 0.0, 100.0, "SourceSansPro-Regular", 12.0, UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0))
        monthValue = addLabel("000.0", view.frame.size.width / 4.0, 70.0, "SourceSansPro-Semibold", 32.0, UIColor(red:0.11, green:0.11, blue: 0.11, alpha:1.0))
        _ = addLabel("1M", view.frame.size.width / 4.0, 100.0, "SourceSansPro-Regular", 12.0, UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0))
        
        _ = addLabel("00:00 PM", 0.0, 200.0, "SourceSansPro-Semibold", 32.0, UIColor(red:0.11, green:0.11, blue: 0.11, alpha:1.0))
        _ = addLabel("00/00/00", 0.0, 230.0, "SourceSansPro-Regular", 12.0, UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0))
    }
    
    private func addLabel(_ text: String, _ xOffset: CGFloat, _ yOffset: CGFloat, _ textFont: String, _ textSize: CGFloat, _ textColor: UIColor) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height / 2.0))
        
        label.center = CGPoint(x: view.frame.size.width / 2.0 + xOffset, y: topMargin + view.frame.size.height / 2.0 + yOffset)
        label.font = UIFont(name: textFont, size: textSize)
        label.textColor = textColor
        label.textAlignment = .center
        label.text = text
        
        self.view.addSubview(label)
        return label
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: topMargin + (view.frame.size.height / 2.0))
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        
        view.addSubview(mapView)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        
        let center = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed")
    }

}
