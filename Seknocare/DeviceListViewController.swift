//
//  DeviceListViewController.swift
//  Seknocare
//
//  Created by Qing Sheng on 2017/3/1.
//  Copyright © 2017年 Qing Sheng. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceListViewController: UITableViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    
    @IBOutlet weak var loading: UIActivityIndicatorView!

    
    
    var peripherals = [CBPeripheral]()
    var manager:CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // bluetooth status
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth open.")
            loading.startAnimating()
            central.scanForPeripherals(withServices: nil, options: nil)
            
            self.view.makeToast("Scaning...", duration: 1.0, position: .center)
            
        } else {
            loading.stopAnimating()
            print("Bluetooth not available.")
            
            // create the alert
            let alert = UIAlertController(title: "Bluetooth", message: "Please turn on bluetooth.", preferredStyle: UIAlertControllerStyle.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    // discover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "BCM99"){
            if(!peripherals.contains(peripheral)){
                peripherals.append(peripheral)
                tableView.reloadData()
                print(peripheral)
            }
//            central.connect(peripheral, options: nil)
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let cell = UITableViewCell()

        cell.textLabel?.text = peripherals[indexPath.row].name
        cell.detailTextLabel?.text = peripherals[indexPath.row].description
        print(peripherals[indexPath.row])
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "unwind", sender: "hello")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for \(segue.identifier)")
        if(segue.identifier == "unwind"){
            if let indexPath = tableView.indexPathForSelectedRow {
                let selectedPeri = peripherals[indexPath.row]
                (segue.destination as! ViewController).peri = selectedPeri
            }
        }
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
