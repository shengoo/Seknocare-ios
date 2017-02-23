//
//  DeviceListViewController.swift
//  Seknocare
//
//  Created by Qing Sheng on 2017/2/23.
//  Copyright © 2017年 Qing Sheng. All rights reserved.
//

import UIKit
import Foundation

class DeviceListViewController: ViewController {
    
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("list")
        loading.startAnimating()
        
    }
}
