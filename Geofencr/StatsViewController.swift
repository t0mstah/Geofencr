//
//  StatsViewController.swift
//  Geofencr
//
//  Created by Tommy Fang on 2/24/17.
//
//

import UIKit

class StatsViewController: UITableViewController {
    
    var items: [String] = ["🏡 Home", "💼 Work", "🎓 School", "💪 Gym", "🍔 Food"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeofencrViewController().roundCorners(self.navigationController!.navigationBar, [.bottomLeft, .bottomRight], 12.0)
        GeofencrViewController().roundCorners(self.tabBarController!.tabBar, [.topLeft, .topRight], 12.0)
        
        self.title = "stats"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fenceCell", for: indexPath)
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tableCellClick") {
            let viewController = segue.destination as! FenceViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell

            viewController.passedValue = currentCell.textLabel?.text            
        }
    }
    
}
