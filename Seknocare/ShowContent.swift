//
//  ShowContent.swift
//  Seknocare
//
//  Created by Qing Sheng on 2017/2/27.
//  Copyright © 2017年 Qing Sheng. All rights reserved.
//

import Foundation


class ShowContent{
    var Mode:String = "Auto"
    var Power:Int = 0
    var Strang:Int = 0
    var Time:String = "0:0"
    var Minute:Int = 0{
        didSet{
            updateTime()
        }
    }
    var Second:Int = 0{
        didSet{
            updateTime()
        }
    }
    var BluetoothState:Bool = false
    
    
    func getContent() -> String {
        if(BluetoothState){
            return "Time:\(Time)  Mode:\(Mode)  Strenth:\(Strang)  Power:\(Power)  " + (BluetoothState ? "Connect" : "Disconnect")
        }else{
            
            return "Disconnect"
        }
    }
    
    func updateTime() {
        Time = "\(Minute):\(Second)"
    }
    
    func minus(){
        if(Second == 0){
            if(Minute == 0){
                return
            }
            Second = 59
            Minute -= 1
        }else{
            Second -= 1
        }
        updateTime()
    }

    
    
    
    
}
