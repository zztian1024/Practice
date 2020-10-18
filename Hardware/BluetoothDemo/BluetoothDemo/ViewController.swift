//
//  ViewController.swift
//  BluetoothDemo
//
//  Created by Tian on 2020/8/11.
//  Copyright © 2020 INKE. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var mgr: CBCentralManager?
    var peripheral: CBPeripheral?
    var devices:[CBPeripheral]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.devices = []
        self.mgr = CBCentralManager.init(delegate: self, queue: nil)
    }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("\(central.state.rawValue)")
    }
    
    @IBAction func searchAction(_ sender: Any) {
        
        if self.mgr != nil, self.mgr?.state.rawValue == 5 {
            self.mgr?.scanForPeripherals(withServices: nil, options: nil)
            
        }
        
    }
    @IBAction func connectAction(_ sender: Any) {
        if let dev = self.devices?.first {
            self.mgr?.connect(dev, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.contains("F50") {
            print("--- \(name)")
            self.devices?.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral = peripheral
            //  设置外设的代理
        self.peripheral!.delegate = self
    
        self.peripheral?.discoverServices(nil)
        self.mgr?.stopScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("发现 service ")
        for s in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: s)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("发现 character ")
        
        for c in service.characteristics! {
            
            peripheral.readValue(for: c)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("获取到数据\(characteristic.value)")
    }
}
