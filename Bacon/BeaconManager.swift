//
//  BeaconManager.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 15/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit

struct BeaconID: Equatable, CustomStringConvertible, Hashable {
    
    let proximityUUID: UUID
    
    init(proximityUUID: UUID) {
        self.proximityUUID = proximityUUID
    }
    
    init(UUIDString: String) {
        self.init(proximityUUID: UUID(uuidString: UUIDString)!)
    }
    
    
    var asString: String {
        get { return "\(proximityUUID.uuidString):" }
    }
    
    var asBeaconRegion: CLBeaconRegion {
        get { return CLBeaconRegion(
            proximityUUID: self.proximityUUID,
            identifier: self.asString) }
    }
    
    var description: String {
        get { return self.asString }
    }
    
    var hashValue: Int {
        get { return self.asString.hashValue }
    }
    
}

func ==(lhs: BeaconID, rhs: BeaconID) -> Bool {
    return lhs.proximityUUID == rhs.proximityUUID
}

extension CLBeacon {
    
    var beaconID: BeaconID {
        get { return BeaconID(
            proximityUUID: proximityUUID) }
    }
    
}
