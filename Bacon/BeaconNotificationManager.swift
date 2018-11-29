//
//  BeaconNotificationManager.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 15/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit

protocol BeaconNotificationManagerDelegate: class {
    func placesNearBeacon(beacon: CLBeacon)
}

class BeaconNotificationManager: NSObject, ESTBeaconManagerDelegate {
    
    static let sharedInstance = BeaconNotificationManager()
    
    private let beaconManager = ESTBeaconManager()
    private let deviceManager = ESTDeviceManager()
    private let dbManager = DBManager.sharedInstance
    public weak var delegate:BeaconNotificationManagerDelegate?

    private var temperature = 0.0
    
    private override init() { //This prevents others from using the default '()' initializer for this class.
        super.init()
        
        let tempNotification = ESTTelemetryNotificationTemperature { (tempInfo) in
            print("beacon ID: \(tempInfo.shortIdentifier), "
                + "temperature: \(tempInfo.temperatureInCelsius) °C")
            self.temperature = tempInfo.temperatureInCelsius.doubleValue
        }
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        self.deviceManager.register(forTelemetryNotification: tempNotification)
        
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
    }
    
    func enableServiceNotifications(for beaconID: BeaconID) {
        let beaconRegion = beaconID.asBeaconRegion
        self.beaconManager.startMonitoring(for: beaconRegion)
    }
    
    func disableServiceNotifications(for beaconID: BeaconID) {
        let beaconRegion = beaconID.asBeaconRegion
        self.beaconManager.stopMonitoring(for: beaconRegion)
    }

    func getTemperature() -> Double {
        return temperature
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        let message = dbManager.getServiceName(serviceUUID: region.proximityUUID.uuidString)
        self.showNotificationWithMessage("Estás en una zona \(message)! Abre Near para más detalles")

        self.beaconManager.startRangingBeacons(in: region)
        
    }
    
    func beaconManager(_ manager: Any, didExitRegion region: CLBeaconRegion) {
        let message = dbManager.getServiceName(serviceUUID: region.proximityUUID.uuidString)
        self.showNotificationWithMessage("Has abandonado la zona \(message). Vuelve pronto!")
        
        self.beaconManager.stopRangingBeacons(in: region)
    }

    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let nearestBeacon = beacons.first{
            delegate?.placesNearBeacon(beacon: nearestBeacon)
        }
    }
    
    fileprivate func showNotificationWithMessage(_ message: String) {
        let notification = UILocalNotification()
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    func beaconManager(_ manager: Any, didChange status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            NSLog("Location Services are disabled for this app, which means it won't be able to detect beacons.")
        }
    }
    
    func beaconManager(_ manager: Any, monitoringDidFailFor region: CLBeaconRegion?, withError error: Error) {
        print("Monitoring failed for region: \(region?.identifier ?? "(unknown)"). Make sure that Bluetooth and Location Services are on, and that Location Services are allowed for this app. Beacons require a Bluetooth Low Energy compatible device: <http://www.bluetooth.com/Pages/Bluetooth-Smart-Devices-List.aspx>. Note that the iOS simulator doesn't support Bluetooth at all. The error was: \(error)")
    }
    
    
}

