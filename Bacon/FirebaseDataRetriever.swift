//
//  FireBaseDataRetriever.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 22/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit
import Firebase

class FirebaseDataRetriever: NSObject {
    
    var ref = FIRDatabase.database().reference()
    var dbManager = DBManager.sharedInstance
    
    static let sharedInstance = FirebaseDataRetriever()
    
    private override init() { //This prevents others from using the default '()' initializer for this class.
        super.init()
    }

    
    func getFirebaseServiceDetails(serviceName: String, completion: @escaping () -> ()){
        ref.child("\(serviceName)/Details").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            if let obtainedUUID = value?["UUID"] as? String {
                if let logoURL = value?["Logo"] as? String {
                    print("De Firebase viene \(logoURL)")
                    self.dbManager.createNewBeaconIdentity(serviceName: serviceName, serviceUUID: obtainedUUID, logoURL: logoURL)
                    print("he creado a \(serviceName) con la UUID \(obtainedUUID)")
                }
            }
            completion()
            
        }) { (error) in
            print("Error found: " + error.localizedDescription)
        }
    }
    
    func getFirebaseServiceStations(serviceName: String) {
        ref.child("\(serviceName)/Stations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let childEnumerator = rest.children
                while let childRest = childEnumerator.nextObject() as? FIRDataSnapshot {
                    
                    let childContent = childRest.value as? NSDictionary
                    let childDetail = childContent?["Detail"] as? String
                    let childMinor = childContent?["Minor"] as? Int32
                    let childMajor = childContent?["Major"] as? Int32
                    let childNotification = childContent?["Notification"] as? String
                    
                    self.dbManager.createNewBeaconDetails(serviceName: serviceName, serviceMajor: childMajor!, serviceMinor: childMinor!, serviceNotification: childNotification!, serviceDetail: childDetail!)
                    
                }
            }
            //completion()
            
        }) { (error) in
            print("Error found: " + error.localizedDescription)
        }
    }
    
    func getFirebaseServiceList(completion: @escaping (Array<String>) -> ()){
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var finalArray: [String] = []
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                finalArray.append(rest.key)
            }
            completion(finalArray)
            
        }) { (error) in
            print("Error found: " + error.localizedDescription)
        }
    }
    
    func getFirebaseServiceLogo(serviceName: String, completion: @escaping (String) -> () ){
        ref.child("\(serviceName)/Details").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
                if let logoURL = value?["Logo"] as? String {
                    completion(logoURL)
                }
            
        }) { (error) in
            print("Error found: " + error.localizedDescription)
        }
    }

}

