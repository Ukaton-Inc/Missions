//
//  AppDelegate.swift
//  missions
//
//  Created by Umar Qattan on 8/18/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    var ble = BLE()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    
    func getJSON(from resource: String) -> String? {
        if let path = Bundle.main.path(forResource: resource, ofType: "csv") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return String(data: data, encoding: .utf8)
              } catch {
                return nil
                   // handle error
              }
        } else {
            return nil
        }
        
    }
    
    func storeSessions() {
        for i in 0..<19 {
            let resource = "session\(i)"
            if let json = self.getJSON(from: resource) {
                let csv = CSwiftV(with: json)
                if let keyedRows = csv.keyedRows {
                    let session: Session = Session(rows: keyedRows)
                    Disk.store(session, to: .documents, as: "\(resource).json")
                    print(session.description())
                }
            }
        }
    }
    
    func saveSessions(_ sessions: [Session]) {
        for (i, session) in sessions.enumerated() {
            let resource = "session\(i).json"
            Disk.store(session, to: .documents, as: resource)
            print(session.description())
        }
    }
    
    func retrieveSessions() -> [Session] {
        var sessions: [Session] = []
        for i in 0..<5 {
            let resource = "session\(i).json"
            if Disk.fileExists(resource, in: .documents) {
                let session = Disk.retrieve(resource, from: .documents, as: Session.self)
                sessions.append(session)
                print(session.description())
            } else {
                continue
            }
        }
        return sessions
    }
    
    func clearFile(at index: Int) {
        let fileName = "session\(index).json"
        Disk.remove(fileName, from: .documents)
    }
    
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + delay, execute: closure)
    }
    
}

