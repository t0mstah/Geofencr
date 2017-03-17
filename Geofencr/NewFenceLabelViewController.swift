//
//  NewFenceLabelViewController.swift
//  Geofencr
//
//  Created by Tommy Fang on 3/15/17.
//
//

import UIKit
import CoreLocation

class NewFenceLabelViewController : UITableViewController {
    
    var items: [String] = ["🏡 Home", "💼 Work", "🎓 School", "💪 Gym", "🍔 Food"]

    var centerCoord: CLLocation!
    var radius: Double!
    
    var nextBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeofencrViewController().roundCorners(self.navigationController!.navigationBar, [.bottomLeft, .bottomRight], 12.0)
        
        self.title = "label"
        
        nextBtn = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(NewFenceLabelViewController.done(_ :)))
        nextBtn.isEnabled = false
        self.navigationItem.rightBarButtonItem = nextBtn
    }
    
    func done(_ sender: UIBarButtonItem!) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        cell.textLabel?.text = self.items[indexPath.row]
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
            nextBtn.isEnabled = true
        }
    }
    
}
