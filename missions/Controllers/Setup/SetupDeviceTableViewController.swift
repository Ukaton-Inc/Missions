//
//  SetupDeviceTableViewController.swift
//  missions
//
//  Created by Umar Qattan on 9/27/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

enum Status: Int {
    case disconnected = 0
    case connected = 1
    
    
}

enum Rate: Int {
    
    case slow = 0
    case moderate = 1
    case fast = 2
    
    var valueForRate: UInt8 {
        switch self {
        case .slow:
            return 200
        case .moderate:
            return 100
        case .fast:
            return 50
        }
    }
}

class SetupDeviceTableViewController: UITableViewController {

    private let appDelegate = UIApplication.shared.delegate as? AppDelegate

    @IBOutlet weak var leftStatusControl: UISegmentedControl!
    
    @IBOutlet weak var leftStreamSwitch: UISwitch!
    @IBOutlet weak var leftRateControl: UISegmentedControl!
    
    private var lastLeftStreamSwitch: Bool = false
    private var lastLeftRateIndex: Rate = .slow
    private var lastLeftStatusIndex: Status = .disconnected
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let leftPeripheral = self.appDelegate?.ble.leftPeripheral {
            self.leftStatusControl!.selectedSegmentIndex = Status.connected.rawValue
            self.leftStreamSwitch!.isOn = true
        } else {
            self.leftStatusControl!.selectedSegmentIndex = Status.disconnected.rawValue
            self.leftStreamSwitch!.isOn = false
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
    }

    @IBAction func onLeftStatusChanged(_ sender: UISegmentedControl) {
        guard let status = Status(rawValue: sender.selectedSegmentIndex)
        else {
            sender.selectedSegmentIndex = Status.disconnected.rawValue
            return
        }
            
        switch status {
        case .disconnected:
            self.appDelegate?.ble.updatePeripheral(side: .left, action: .stopStream)
        case .connected:
            self.appDelegate?.ble.updatePeripheral(side: .left, action: .startStream)
        }
        
        self.lastLeftStatusIndex = status
    }
    
    @IBAction func onStreamChanged(_ sender: UISwitch) {
        let streamAction = sender.isOn ? BLEAction.startStream : BLEAction.stopStream
        self.appDelegate?.ble.updatePeripheral(side: .left, action: streamAction)
    }
    
    @IBAction func onLeftRateChanged(_ sender: UISegmentedControl) {
        guard
            let rate = Rate(rawValue: sender.selectedSegmentIndex) else { return }
        
        self.appDelegate?.ble.updatePeripheral(side: .left, action: .samplingRate, samplingRate: rate.valueForRate)
        self.lastLeftRateIndex = rate
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
