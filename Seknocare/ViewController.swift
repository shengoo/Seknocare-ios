//
//  ViewController.swift
//  Seknocare
//
//  Created by Qing Sheng on 2016/12/30.
//  Copyright © 2016年 Qing Sheng. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,
    CBCentralManagerDelegate,
CBPeripheralDelegate{
    
    var manager:CBCentralManager!
    var discoverPeripherals = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("Bluetooth open.")
            central.scanForPeripherals(withServices: nil, options: nil)
            
        } else {
            print("Bluetooth not available.")
                
            // create the alert
            let alert = UIAlertController(title: "Bluetooth", message: "Please turn on bluetooth.", preferredStyle: UIAlertControllerStyle.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "BCM99"){
            discoverPeripherals.append(peripheral)
            print(peripheral)

        }
    }
    
    
    

}

