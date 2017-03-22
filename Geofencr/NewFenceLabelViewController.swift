//
//  NewFenceLabelViewController.swift
//  Geofencr
//
//  Created by Tommy Fang on 3/15/17.
//
//

import UIKit
import CoreLocation
import CoreData

class NewFenceLabelViewController : UITableViewController {
    
//    var items: [String] = ["🏡 Home", "💼 Work", "🎓 School", "💪 Gym", "🍔 Food"]
    
    var centerCoord: CLLocation!
    var radius: Double!
    
    var doneBtn: UIBarButtonItem!
    var selectedIndex: Int!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fences: [Fence] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GeofencrViewController().roundCorners(self.navigationController!.navigationBar, [.bottomLeft, .bottomRight], 12.0)
        
        self.title = "label"
        
        doneBtn = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(NewFenceLabelViewController.done(_ :)))
        doneBtn.isEnabled = false
        self.navigationItem.rightBarButtonItem = doneBtn
    }
    
    func done(_ sender: UIBarButtonItem!) {
        fences[selectedIndex].latitude = centerCoord.coordinate.latitude
        fences[selectedIndex].longitude = centerCoord.coordinate.longitude
        fences[selectedIndex].radius = radius
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            fences = try context.fetch(Fence.fetchRequest())
        } catch {
            print("Fetching failed")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fences.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        cell.textLabel?.text = fences[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            selectedIndex = indexPath.row
            doneBtn.isEnabled = true
        }
    }
    
}
