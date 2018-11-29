//
//  PdnCellTableViewCell.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 13/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit

class PdnCellTableViewCell: UITableViewCell {
    
    let dbManager = DBManager.sharedInstance
    let beaconNotificationManager = BeaconNotificationManager.sharedInstance
    
    @IBOutlet weak var TxtPdnName: UILabel!
    @IBOutlet weak var SwtPdnActive: UISwitch!
    @IBOutlet weak var ImgServiceLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.ImgServiceLogo.layer.cornerRadius = self.ImgServiceLogo.frame.size.width/2
        self.ImgServiceLogo.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func getCellName() -> String {
        return TxtPdnName.text!
    }

    @IBAction func statusChanged(_ sender: UISwitch) {
        dbManager.setActiveStatus(serviceName: TxtPdnName.text!, activeService: sender.isOn)
        let modifiedPdnUUID = dbManager.getServiceUUID(serviceName: TxtPdnName.text!)
        if(sender.isOn) {
            self.beaconNotificationManager.enableServiceNotifications(for: BeaconID(UUIDString: modifiedPdnUUID))
        }
        else {
            self.besaconNotificationManager.disableServiceNotifications(for: BeaconID(UUIDString: modifiedPdnUUID))
        }
    }

}
