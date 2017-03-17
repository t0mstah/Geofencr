//
//  GeofencrViewController.swift
//  Geofencr
//
//  Created by Tommy Fang on 2/24/17.
//
//

import UIKit
import MapKit
import CoreLocation

class GeofencrViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var topMargin: CGFloat!
    
    var locationManager: CLLocationManager!
    var mapView: MKMapView!
    var searchController: UISearchController!
    
    var locateMe: UIButton!
    var addFence: UIButton!
    
    var located = false
    
    var lastLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundCorners(self.navigationController!.navigationBar, [.bottomLeft, .bottomRight], 12.0)
        roundCorners(self.tabBarController!.tabBar, [.topLeft, .topRight], 12.0)
        
        topMargin = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.size.height
        self.title = "geofencr"
        
        mapView = MKMapView()
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 10.0
            locationManager.startUpdatingLocation()
        }
        
        setupSearch()
    }
    
    func roundCorners(_ subView: UIView, _ corners: UIRectCorner, _ radius: CGFloat) {
        let path = UIBezierPath(roundedRect: subView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        subView.layer.mask = mask
    }
    
    private func setupSearch() {
        let searchTableController = storyboard!.instantiateViewController(withIdentifier: "SearchTableController") as! SearchTableController
        searchController = UISearchController(searchResultsController: searchTableController)
        searchController.searchResultsUpdater = searchTableController
        
        navigationItem.titleView = searchController.searchBar
        
        let searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for a place or address"
        
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.font = UIFont(name: "SourceSansPro-Regular", size: 17.0)
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        searchBar.setValue("cancel", forKey:"_cancelButtonText")

        searchTableController.mapView = mapView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        mapView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        mapView.showsUserLocation = true
        
        self.view.addSubview(mapView)
        locateMe = addButton(view.frame.size.width / 10.0, view.frame.size.width / 10.0, "location.png", [.topLeft, .topRight], (view.frame.size.width / 10.0) - 0.5)
        addFence = addButton(view.frame.size.width / 10.0, view.frame.size.width / 5.0, "add.png", [.bottomLeft, .bottomRight], 0.0)
        
        locateMe.setImage(UIImage(named: "location.png") , for: .highlighted)
        located = false
        
        locateMe.addTarget(self, action: #selector(GeofencrViewController.locate(_ :)), for: .touchUpInside)
        addFence.addTarget(self, action: #selector(GeofencrViewController.new(_ :)), for: .touchUpInside)
    }
    
    func locate(_ sender: UIButton!) {
        if sender != nil {
            locateMe.setImage(UIImage(named: "location_selected.png") , for: .normal)
            located = true
        }
        
        let center = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if located == true {
            locateMe.setImage(UIImage(named: "location.png") , for: .normal)
            located = false
        }
    }
    
    func new(_ sender: UIButton!) {
        let newFenceViewController = storyboard!.instantiateViewController(withIdentifier: "NewFenceViewController") as! NewFenceViewController
        let navigationController = UINavigationController(rootViewController: newFenceViewController)
        
        newFenceViewController.mapView = mapView
        newFenceViewController.topMargin = topMargin
        
        present(navigationController, animated: true, completion: nil)
    }
    
    private func addButton(_ size: CGFloat, _ yCoord: CGFloat, _ imageName: String, _ corners: UIRectCorner, _ borderOffset: CGFloat) -> UIButton {
        let button = UIButton(frame: CGRect(x: size, y: topMargin + yCoord, width: size, height: size))
        
        button.backgroundColor = UIColor(red: 0.78, green: 0.97, blue: 0.77, alpha: 0.9)
        button.setImage(UIImage(named: imageName) , for: .normal)
        let edgeInset = size / 4.0
        button.imageEdgeInsets = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        
        roundCorners(button, corners, 12.0)
        
        let border = UIView()
        border.frame = CGRect(x: 0.0, y: borderOffset, width: size, height: 0.5)
        border.backgroundColor = UIColor(red: 0.12, green: 0.51, blue: 0.30, alpha: 0.5)
        button.addSubview(border)
        
        self.view.addSubview(button)
        return button
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last!
        locate(nil)
    }
 
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed")
    }
    
}
