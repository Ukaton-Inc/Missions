//
//  SelectDeviceTableViewController.swift
//  missions
//
//  Created by Umar Qattan on 9/23/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

struct SelectDeviceTableViewModel {
    var devices: [SelectDeviceTableViewCellModel]
}

class SelectDeviceTableViewController: UITableViewController {

    var viewModel: SelectDeviceTableViewModel = SelectDeviceTableViewModel(
        devices: [
        SelectDeviceTableViewCellModel(image: "left_mission", label: "Left"),
        SelectDeviceTableViewCellModel(image: "right_mission", label: "Right")
    ])

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Devices"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .done, target: self, action: #selector(onSettingsTapped))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.viewModel.devices.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectDeviceTableViewCellId", for: indexPath) as? SelectDeviceTableViewCell else { return UITableViewCell() }
    
        cell.configure(cellModel: self.viewModel.devices[indexPath.row])
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "showLeftDetail", sender: nil)
        }
        
        if indexPath.row == 1 {
            self.performSegue(withIdentifier: "showRightDetail", sender: nil)
        }
    }
    
    @objc func onSettingsTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "settingsSegue", sender: sender)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let left = segue.destination as? LeftMissionsViewController {
            
        } else if let right = segue.destination as? RightMissionsViewController {
            
        } else if let settings = segue.destination as? SetupDeviceTableViewController {
            
        }
    }
    

}
