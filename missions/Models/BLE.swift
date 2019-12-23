//
//  BLE.swift
//  missions
//
//  Created by Umar Qattan on 9/15/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit
import CoreBluetooth


enum BLEDeviceSide: String {
    case left = "left"
    case right = "right"
}

enum BLEAction: UInt8 {
    case stopStream
    case startStream
    case samplingRate
    
    func actionForByte(_ byte: UInt8) -> BLEAction {
        switch byte {
        case 0:
            return .stopStream
        case 1:
            return .startStream
        default:
            return .samplingRate
        }
    }
}

class BLE: NSObject {
    
    // bluetooth variables
    var centralManager: CBCentralManager?
    var peripherals = [CBPeripheral]()
    var leftPeripheral: CBPeripheral?
    var rightPeripheral: CBPeripheral?
    var rxCharacteristicLeft: CBCharacteristic?
    var rxCharacteristicRight: CBCharacteristic?
    var connectedPeripherals = Int(0)
    var isConnected: Bool = false
    
    override init() {
        super.init()
        self.startManager()
    }
    
    func updatePeripheral(samplingRate: inout UInt8) {
        guard let rxCharacteristicLeft = self.rxCharacteristicLeft else { return }
        
        let data = Data(bytes: &samplingRate,
                             count: MemoryLayout.size(ofValue: samplingRate))
        print("Data is \(String(format: "%.2x", [data]))")
        self.peripherals.first?.writeValue(data, for: rxCharacteristicLeft, type: .withResponse)
        
    }
    
    func updatePeripheral(side: BLEDeviceSide, action: BLEAction, samplingRate: UInt8 = 50) {
        switch action {
        case .stopStream:
            if let characteristic = self.rxCharacteristicLeft {
                if side == .left {
                    self.leftPeripheral?.setNotifyValue(false, for: characteristic)
                } else if side == .right {
                    self.rightPeripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        case .startStream:
            if let characteristic = self.rxCharacteristicLeft {
                if side == .left {
                    self.leftPeripheral?.setNotifyValue(true, for: characteristic)
                } else if side == .right {
                    self.rightPeripheral?.setNotifyValue(true, for: characteristic)
                }
            }
        case .samplingRate:
            var bytes: UInt8 = samplingRate
            let data = Data(bytes: &bytes,
                                 count: MemoryLayout.size(ofValue: bytes))
            print("Data is \(String(format: "%.2x", [data]))")
            
            if let characteristic = self.rxCharacteristicLeft {
                if side == .left {
                    self.leftPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
                } else if side == .right {
                    self.rightPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
                }
            }
        }
    }
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
        
        if name.contains(Strings.Missions.left) || name.contains(Strings.Missions.right) {
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
                
                if name.contains(Strings.Missions.left) {
                    self.leftPeripheral = peripheral
                    self.rxCharacteristicLeft = characteristic
                } else if name.contains(Strings.Missions.right) {
                    self.rightPeripheral = peripheral
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
            if let rxCharacteristicLeft = self.rxCharacteristicLeft,
                characteristic == rxCharacteristicLeft {
                if let data = characteristic.value {
                    self.leftPeripheral = peripheral
                    self.notifyWithData(data, side: .left)
                }
            }
            
            if let rxCharacteristicRight = self.rxCharacteristicRight,
                characteristic == rxCharacteristicRight {
                if let data = characteristic.value {
                    self.rightPeripheral = peripheral
                    self.notifyWithData(data, side: .right)
                }
            }
        }
    }
    
    // Peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("Updated notification state for characteristic: \(characteristic)")
        if let rxCharacteristicLeft = self.rxCharacteristicLeft,
            characteristic == rxCharacteristicLeft {
            if let _ = characteristic.value {
                self.leftPeripheral = peripheral
            }
        }
        
        if let rxCharacteristicRight = self.rxCharacteristicRight,
            characteristic == rxCharacteristicRight {
            if let _ = characteristic.value {
                self.rightPeripheral = peripheral
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
    // i.e., LEFT0 and RIGHT0
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("Connected to peripheral: \(String(describing: peripheral.name))")
        if self.peripherals.count == 2 {
            self.isConnected = true
            self.stopScan()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
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
                    self.isConnected = false
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
    
    /// A Class function that takes a data object, casts it to a byte array, and chunks it into groups of 2 bytes to reconstruct the transmitted sensor value array.
    func bytesToUInt16() -> [UInt16]? {
        print("Packet Size: [\(self.count) bytes]")
        guard self.count == 12 else {
            return nil
        }

        let byteArray: [UInt8] = [UInt8](self)
        let chunks = byteArray.chunked(into: 2)
        var sensors: [UInt16] = []
        for chunk in chunks {
            var s_i: UInt16 = 0
            let data_i = NSData(bytes: chunk, length: 2)
            data_i.getBytes(&s_i, length: 2)
            s_i = UInt16(littleEndian: s_i)
            sensors.append(s_i)
        }
        
        for (i, sensor) in sensors.enumerated() {
            print("""
                    s_\(i): \(sensor)
                """)
        }
        return sensors
    }
}

extension BLE {
    
    func notifyWithData(_ data: Data, side: BLEDeviceSide) {
        guard
            let sensors = data.bytesToUInt16(),
            sensors.count == 6
        else { return }
        let values = sensors.map( { Int($0) })
        NotificationCenter.postSensorValues(
            side: side,
            values: values
        )
    }
}
