//
//  NewFenceViewController.swift
//  Geofencr
//
//  Created by Tommy Fang on 3/15/17.
//
//

import UIKit
import MapKit

class NewFenceViewController : UIViewController {
    
    var mapView: MKMapView!
    var topMargin: CGFloat!
    
    var nextBtn: UIBarButtonItem!
    
    var centerPoint: CGPoint?
    var path: UIBezierPath?
    var shapeLayer: CAShapeLayer?
    
    var centerCoord: CLLocation?
    var radius: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeofencrViewController().roundCorners(self.navigationController!.navigationBar, [.bottomLeft, .bottomRight], 12.0)
        
        self.title = "new fence"
        
        let cancelBtn = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(NewFenceViewController.closeModal(_ :)))
        self.navigationItem.leftBarButtonItem = cancelBtn
        
        nextBtn = UIBarButtonItem(title: "next", style: .plain, target: self, action: #selector(NewFenceViewController.nextScreen(_ :)))
        nextBtn.isEnabled = false
        self.navigationItem.rightBarButtonItem = nextBtn
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(NewFenceViewController.handlePan(_ :)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer!) {
        let touchLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        
        if gestureRecognizer.state == .began {
            centerPoint = touchLocation
            path = UIBezierPath(arcCenter: centerPoint!, radius: 0.0, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
            
            if shapeLayer != nil {
                shapeLayer!.removeFromSuperlayer()
            }
            
            shapeLayer = CAShapeLayer()
            shapeLayer!.path = path!.cgPath
            shapeLayer!.fillColor = UIColor(red: 0.78, green: 0.97, blue: 0.77, alpha: 0.5).cgColor
            shapeLayer!.strokeColor = UIColor(red: 0.12, green: 0.51, blue: 0.30, alpha: 1.0).cgColor
            shapeLayer!.lineWidth = 2.0
            gestureRecognizer.view?.layer.addSublayer(shapeLayer!)
        } else if gestureRecognizer.state == .changed {
            path!.removeAllPoints()
            path!.addArc(withCenter: centerPoint!, radius: cgPointDistance(centerPoint!, touchLocation), startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
            shapeLayer!.path = path!.cgPath
            
            centerCoord = CLLocation(coordinate: mapView.convert(centerPoint!, toCoordinateFrom: gestureRecognizer.view), altitude: 0.0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: Date())
            let endCoord = CLLocation(coordinate: mapView.convert(touchLocation, toCoordinateFrom: gestureRecognizer.view), altitude: 0.0, horizontalAccuracy: 10.0, verticalAccuracy: 10.0, timestamp: Date())
            
            radius = centerCoord!.distance(from: endCoord)
            
            nextBtn.isEnabled = true
        }
    }
    
    private func cgPointDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func closeModal(_ sender: UIBarButtonItem!) {
        dismiss(animated: true, completion: nil)
    }
    
    func nextScreen(_ sender: UIBarButtonItem!) {
        performSegue(withIdentifier: "newNext", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        mapView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height)
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        mapView.showsUserLocation = true
        
        self.view.addSubview(mapView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newNext") {
            let viewController = segue.destination as! NewFenceLabelViewController
            viewController.centerCoord = centerCoord
            viewController.radius = radius
        }
    }
    
}
