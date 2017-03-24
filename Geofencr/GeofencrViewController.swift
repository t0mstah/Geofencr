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
import GooglePlaces

class GeofencrViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GMSAutocompleteResultsViewControllerDelegate {

    var topMargin: CGFloat!
    let coordinateDelta = 0.025
    
    var locationManager: CLLocationManager!
    var mapView: MKMapView!
    
    var resultsViewController: GMSAutocompleteResultsViewController!
    var searchController: UISearchController!
    var searchView: UIView!
    
    var locateMe: UIBarButtonItem!
    var addFence: UIBarButtonItem!
    
    var initiallyLocated = false
    
    var lastLocation: CLLocation!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fences: [Fence] = []
    var initialFences: [String] = ["🏡 Home", "💼 Work", "🎓 School", "💪 Gym", "🍔 Food"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundCorners(self.tabBarController!.tabBar, [.topLeft, .topRight], 12.0)
        
        topMargin = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.size.height
        self.title = "geofencr"
        
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
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
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController.delegate = self
        
        let left = mapView.region.center.latitude - coordinateDelta
        let right = mapView.region.center.latitude + coordinateDelta
        let top = mapView.region.center.longitude - coordinateDelta
        let bottom = mapView.region.center.longitude + coordinateDelta
        
        resultsViewController.autocompleteBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: left, longitude: top), coordinate: CLLocationCoordinate2D(latitude: right, longitude: bottom))
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        
        searchView = UIView(frame: CGRect(x: 0, y: topMargin, width: view.frame.size.width, height: 68.0))
        
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search for a place or address"
        
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.font = UIFont(name: "SourceSansPro-Regular", size: 17.0)
        
        searchBar.setValue("cancel", forKey:"_cancelButtonText")
        
        searchBar.barTintColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0)
        searchBar.tintColor = UIColor(red: 0.78, green: 0.97, blue: 0.77, alpha: 1.0)
        
        searchView.addSubview(searchBar)
        
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
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
        
        locateMe = UIBarButtonItem(image: UIImage(named: "location"), style: .plain, target: self, action: #selector(GeofencrViewController.locate(_ :)))
        self.navigationItem.leftBarButtonItem = locateMe
        
        addFence = UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(GeofencrViewController.new(_ :)))
        self.navigationItem.rightBarButtonItem = addFence
        
        self.view.addSubview(searchView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locate(_ sender: UIButton!) {
        let center = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: coordinateDelta, longitudeDelta: coordinateDelta))
            
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
    }
    
    func new(_ sender: UIButton!) {
        let newFenceViewController = storyboard!.instantiateViewController(withIdentifier: "NewFenceViewController") as! NewFenceViewController
        let navigationController = UINavigationController(rootViewController: newFenceViewController)
        
        newFenceViewController.mapView = mapView
        newFenceViewController.topMargin = topMargin
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func addFences() {
        mapView.removeAnnotations(self.mapView.annotations)
        for fence in fences {
            let pin = CustomPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(fence.latitude, fence.longitude)
            pin.title = fence.name
            mapView.addAnnotation(pin)
        }
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
        if annotation is MKUserLocation || !(annotation is CustomPointAnnotation) {
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
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        addFences()

        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        annotation.subtitle = place.formattedAddress
        mapView.addAnnotation(annotation)
                
        let region = MKCoordinateRegion(center: place.coordinate, span: MKCoordinateSpan(latitudeDelta: coordinateDelta, longitudeDelta: coordinateDelta))
        mapView.setRegion(region, animated: true)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    
}
