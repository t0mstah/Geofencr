//
//  StatsViewController.swift
//  Geofencr
//
//  Created by Tommy Fang on 2/24/17.
//
//

import UIKit
import CoreData

class StatsViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fences: [Fence] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeofencrViewController().roundCorners(self.navigationController!.navigationBar, [.bottomLeft, .bottomRight], 12.0)
        GeofencrViewController().roundCorners(self.tabBarController!.tabBar, [.topLeft, .topRight], 12.0)
        
        self.title = "stats"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "fenceCell", for: indexPath)
        cell.textLabel?.text = fences[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tableCellClick") {
            let viewController = segue.destination as! FenceViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            viewController.fence = fences[indexPath.row]
        }
    }
    
}
