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
    
    var content:ShowContent = ShowContent()
    
    var timer:Timer = Timer()
    
    
    var chara:CBCharacteristic!;
    var peri:CBPeripheral!;

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bluetoothbtn: UIButton!
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        updateText()
        // Do any additional setup after loading the view, typically from a nib.
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
            
        case "1":
            sendMessage(0xC1)
            setMode("PRESS")
            break
        case "2":
            sendMessage(0xA8)
            setMode("NIP")
            break
        case "3":
            sendMessage(0xA2)
            setMode("PRICK")
            break
        case "4":
            sendMessage(0xA7)
            setMode("RAP")
            
            break
        case "5":
            sendMessage(0xA3)
            setMode("STROKE")
            
            break
        case "6":
            sendMessage(0xA6)
            setMode("FLUTTER")
            
            break
        case "7":
            sendMessage(0xA4)
            setMode("SCRAPE")
            
            break
        case "8":
            sendMessage(0xA5)
            setMode("PINCH")
            
            break
        case "9":
            sendMessage(0xC0)
            setMode("AUTO")
            
            break
            
        case "11":
            showSetTimeDialog()
            break
        case "12":
            sendMessage(0xC0)
            break
        case "13":
            sendMessage(0xC0)
            break
        case "14":
            sendMessage(0xC0)
            break
            
        case "15":
            print("15")
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let list = storyboard?.instantiateViewController(withIdentifier: "devicelist")
//            list?.modalPresentationStyle = .popover
//            list?.popoverPresentationController?.sourceView = bluetoothbtn
//            list?.popoverPresentationController?.sourceRect = bluetoothbtn.bounds
//            list?.popoverPresentationController?.arrowDirection = .any
//            navigationController?.pushViewController(list!, animated: true)
        
//            present(list!, animated: true, completion: nil)
            
            restart()
            break
        default:
            print("default")
        }
    }
    
    func showSetTimeDialog(){
        let optionMenu = UIAlertController(title: nil, message: "Set Time", preferredStyle: .actionSheet)
        
        // 2
        let mi10 = UIAlertAction(title: "10 minutes", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.setTime(10)
        })
        let mi20 = UIAlertAction(title: "20 minutes", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.setTime(20)
        })
        
        let mi30 = UIAlertAction(title: "20 minutes", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.setTime(30)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(mi10)
        optionMenu.addAction(mi20)
        optionMenu.addAction(mi30)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func setTime(_ minute:Int){
        content.Minute = minute
        content.Second = 0
        updateText()
    }
    
    func updateText() {
        print(content.getContent())
        label.text = content.getContent()
    }
    
    func setMode(_ mode:String) {
        content.Mode = mode
        content.Strang = 0
        stop()
        setTime(10)
    }
    
    func restart(){
        
        // stop and disconnect
        manager.stopScan()
        manager.cancelPeripheralConnection(peri)
        
        // start and discover
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func start(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.tick), userInfo: nil, repeats: true)
    }
    
    func tick(){
        print("tick")
        timer.invalidate()
    }

    
    func stop(){
        sendMessage(0xB2);
        timer.invalidate()
    }
    
    func increaseIntensity(){
        
    }
    
    func decreaseIntensity(){
        
    }
    
    
    

}

