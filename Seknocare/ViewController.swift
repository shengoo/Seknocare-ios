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
    
    
    var chara:CBCharacteristic!;
    var peri:CBPeripheral!;

    @IBOutlet weak var bluetoothbtn: UIButton!
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // bluetooth status
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
    
    // discover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(peripheral.name == "BCM99"){
            discoverPeripherals.append(peripheral)
            print(peripheral)
            central.connect(peripheral, options: nil)
        }
    }
    
    // fail to connect
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let alert = UIAlertController(title: "Connect failed.", message: "Connect failed.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // discover services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil)
        {
            print(peripheral.name! + (error?.localizedDescription)!);
            return;
        }
        for service in peripheral.services! {
//            print("\(service.uuid)")
            //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
            if("\(service.uuid)" == "Battery"){
                print(service.uuid);
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // discover characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if((error) != nil){
            showError((error?.localizedDescription)!)
            return;
        }
        for characteristic in service.characteristics!{
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if("\(characteristic.uuid)" == "Battery Level"){
            peri = peripheral
            chara = characteristic
            var out: UInt8 = 0
            characteristic.value?.copyBytes(to: &out, count: MemoryLayout<Int>.size)
            print("battery level:\(out)")
            
            sendMessage(0xE0);
            sendMessage(0xC0);
            sendMessage(0xF2 + 1);

        }
    }
    
    
    
    func showError(_ msg: String){
        
        // create the alert
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendMessage(_ msg:NSInteger){
        var src = msg
        let data: NSData = NSData(bytes: &src, length: MemoryLayout<Int>.size)
        peri.writeValue(data as Data, for: chara, type: CBCharacteristicWriteType.withResponse)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        print(sender.currentTitle!)
        switch sender.currentTitle! {
        case "15":
            print("15")
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let list = storyboard?.instantiateViewController(withIdentifier: "devicelist")
            list?.modalPresentationStyle = .popover
            list?.popoverPresentationController?.sourceView = bluetoothbtn
            list?.popoverPresentationController?.sourceRect = bluetoothbtn.bounds
//            list?.popoverPresentationController?.arrowDirection = .any
//            navigationController?.pushViewController(list!, animated: true)
        
            present(list!, animated: true, completion: nil)
            break
        default:
            print("default")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showlist"{
            print("show list")
            
            UIApplication.shared.statusBarStyle = .default
            self.navigationController?.isNavigationBarHidden = false
        }
    }

}

