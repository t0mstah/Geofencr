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
import CoreData

class GeofencrViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var topMargin: CGFloat!
    
    var locationManager: CLLocationManager!
    var mapView: MKMapView!
    var searchController: UISearchController!
    
    var locateMe: UIButton!
    var addFence: UIButton!
    
    var initiallyLocated = false
    var buttonLocated = false
    
    var lastLocation: CLLocation!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fences: [Fence] = []
    var initialFences: [String] = ["🏡 Home", "💼 Work", "🎓 School", "💪 Gym", "🍔 Food"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundCorners(self.navigationController!.navigationBar, [.bottomLeft, .bottomRight], 12.0)
        roundCorners(self.tabBarController!.tabBar, [.topLeft, .topRight], 12.0)
        
        topMargin = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.size.height
        self.title = "geofencr"
        
        locationManager = CLLocationManager()
        
        if !CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        mapView = MKMapView()
        mapView.delegate = self

        setupSearch()
        initFences()
    }
    
    private func initFences() {
        do {
            fences = try context.fetch(Fence.fetchRequest())
            if fences.count == 0 {
                for fenceName in initialFences {
                    let fence = Fence(context: context)
                    fence.name = fenceName
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                }
            }
        } catch {
            print("fetching failed")
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        
        addFences()

        locateMe = addButton(view.frame.size.width / 10.0, view.frame.size.width / 10.0, "location.png", [.topLeft, .topRight], (view.frame.size.width / 10.0) - 0.5)
        addFence = addButton(view.frame.size.width / 10.0, view.frame.size.width / 5.0, "add.png", [.bottomLeft, .bottomRight], 0.0)
        
        locateMe.setImage(UIImage(named: "location.png") , for: .highlighted)
        buttonLocated = false
        
        locateMe.addTarget(self, action: #selector(GeofencrViewController.locate(_ :)), for: .touchUpInside)
        addFence.addTarget(self, action: #selector(GeofencrViewController.new(_ :)), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locate(_ sender: UIButton!) {
        if !buttonLocated {
            locateMe.setImage(UIImage(named: "location_selected.png") , for: .normal)
            buttonLocated = true
            
            let center = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
                
            mapView.showsUserLocation = true
            mapView.setRegion(region, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if buttonLocated == true {
            locateMe.setImage(UIImage(named: "location.png") , for: .normal)
            buttonLocated = false
        }
    }
    
    func new(_ sender: UIButton!) {
        let newFenceViewController = storyboard!.instantiateViewController(withIdentifier: "NewFenceViewController") as! NewFenceViewController
        let navigationController = UINavigationController(rootViewController: newFenceViewController)
        
        newFenceViewController.mapView = mapView
        newFenceViewController.topMargin = topMargin
        
        present(navigationController, animated: true, completion: nil)
    }
    
    private func addFences() {
        mapView.removeAnnotations(self.mapView.annotations)
        for fence in fences {
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(fence.latitude, fence.longitude)
            pin.title = fence.name
            mapView.addAnnotation(pin)
        }
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
        
        if !initiallyLocated {
            locate(nil)
            initiallyLocated = true
        }
    }
 
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "fencePin")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "fencePin")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = UIImage(named: "pin")
        
        return annotationView
    }
    
}
