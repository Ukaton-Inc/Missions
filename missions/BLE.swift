//
//  BLE.swift
//  missions
//
//  Created by Umar Qattan on 9/15/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLE: NSObject {
    
    // bluetooth variables
    var centralManager: CBCentralManager?
    var peripherals = [CBPeripheral]()
    var rxCharacteristicLeft: CBCharacteristic?
    var rxCharacteristicRight: CBCharacteristic?
    var connectedPeripherals = Int(0)
    
    // demo variables
    var leftSensorArray:[Int] = [0,0,0,0,0,0]
    var rightSensorArray:[Int] = [0,0,0,0,0,0]
    
    override init() {
        super.init()
        self.startManager()
    }
    

    

    
//    func removeObservers() {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NotifyLeft"), object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NotifyRight"), object: nil)
//    }
}

extension BLE: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func startManager() {
        print("Starting the central manager.")
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("The central manager updated state.")
        
        switch central.state {
        case .poweredOff:
            print("Powered Off")
        case .poweredOn:
            print("Powered On")
            print("Scanning...")
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        case .resetting:
            print("Resetting")
        case .unauthorized:
            print("Unauthorized")
        case .unsupported:
            print("Unsupported")
        case .unknown:
            print("Unknown")
        @unknown default:
            print("Unknown")
        }
    }
    
    // Central Bluetooth manager discovered a peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Looking for peripherals...")
        
        guard let name = peripheral.name else { return }
        
        print("Found peripheral named: \(name)")
        
        if name == "LEFT" || name == "RIGHT" {
            self.peripherals.append(peripheral)
            central.connect(
                peripheral,
                options: [CBConnectPeripheralOptionNotifyOnConnectionKey : true]
            )
        }
    }
    
    // Peripheral discovered characteristic(s) for service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Peripheral discovered characteristics for service: \(service)")
        
        guard let name = peripheral.name else { return }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Characteristic UUID: \(characteristic.uuid.uuidString)")
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
                
                if name == "LEFT" {
                    self.rxCharacteristicLeft = characteristic
                } else if name == "RIGHT" {
                    self.rxCharacteristicRight = characteristic
                }
            }
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    
    // Peripheral updated value for characteristic(s)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Updated value for characteristic: \(characteristic.uuid)")
            if let rxCharacteristicLeft = self.rxCharacteristicLeft,
                characteristic == rxCharacteristicLeft {
                if let value = characteristic.value, let asciiString = value.bytesToString(), let values = value.bytesToInt() {
                    
                    print("Value received: \(asciiString).")
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "NotifyLeft"),
                        object: nil,
                        userInfo: ["string": asciiString,
                                   "value_left": values]
                    )
                }
            }
            
            if let rxCharacteristicRight = self.rxCharacteristicRight,
                characteristic == rxCharacteristicRight {
                if let value = characteristic.value,
                    let asciiString = String(bytes: value, encoding: .utf8) {
                    print("Value received: \(asciiString).")
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name(rawValue: "NotifyRight"),
                        object: nil,
                        userInfo: ["value_right": asciiString]
                    )
                }
            }
        }
    }
    
    // Peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("Updated notification state for characteristic: \(characteristic)")
        if let rxCharacteristicLeft = self.rxCharacteristicLeft,
            characteristic == rxCharacteristicLeft {
            if let value = characteristic.value,
                let asciiString = String(data: value, encoding: .utf8) {
                print("First left value received: \(asciiString).")
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "NotifyLeft"),
                    object: nil,
                    userInfo: ["value_left": asciiString]
                )
            }
        }
        
        if let rxCharacteristicRight = self.rxCharacteristicRight,
            characteristic == rxCharacteristicRight {
            if let value = characteristic.value,
                let asciiString = String(data: value, encoding: .utf8) {
                print("First right value received: \(asciiString).")
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "NotifyRight"),
                    object: nil,
                    userInfo: ["value_right": asciiString]
                )
            }
        }
        
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services, let service = services.first {
            print("Peripheral discovered services.")
            print("Currently discovering characteristics for service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    
    // Central manager connected to a peripheral. Stop scanning when connected to 2 peripherals
    // i.e., LEFT and RIGHT
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("Connected to peripheral: \(String(describing: peripheral.name))")
        if self.peripherals.count == 1 {
            self.stopScan()
        }
    }
    
    // Central manager disconnected from a peripheral. Find the current peripheral amongst the cached peripherals and
    //
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("Attempting to disconnect from peripheral...")
        
        if let error = error {
            print(error.localizedDescription)
        } else {
            if self.peripherals.count != 0 {
                if let peripheralToDisconnect = self.peripherals.filter({$0 == peripheral}).first {
                    print("Disconnected from peripheral \(peripheral)")
                    peripheralToDisconnect.delegate = nil
                    self.peripherals = self.peripherals.filter({$0 != peripheral})
                }
            }
            self.startManager()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func stopScan() {
        print("Central Manager stopped scanning for peripherals.")
        self.centralManager?.stopScan()
    }
}

extension Data {
    
    func bytesToString() -> String? {
        guard self.count == 6 else { return nil }
        var string = "["
        for i in 0..<self.count {
            if i < self.count - 1 {
                string += "\(String(Int(self[i]))), "
            } else {
                string += "\(String(Int(self[i])))]"
            }
        }
        
        return string
    }
    
    func bytesToInt() -> [Int]? {
        guard self.count == 6 else { return nil }
        var values = [Int]()
        for value in self {
            values.append(Int(value))
        }
        
        return values
    }
   
}
