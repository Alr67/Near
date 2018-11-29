//
//  PdnDownloadCellTableViewCell.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 20/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol DownloadCellControllerDelegate: class {
    func resfreshTable()
}

class PdnDownloadCellTableViewCell: UITableViewCell, NVActivityIndicatorViewable  {
    
    private let dbManager = DBManager.sharedInstance
    private let beaconNotificationManager = BeaconNotificationManager.sharedInstance
    private let firebaseDataRetriever = FirebaseDataRetriever.sharedInstance
    weak var delegate:DownloadCellControllerDelegate?
    
    @IBOutlet weak var TxtPdnName: UILabel!
    @IBOutlet weak var BtnDownload: UIButton!
    @IBOutlet weak var ImgLogo: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.ImgLogo.layer.cornerRadius = self.ImgLogo.frame.size.width/2
        self.ImgLogo.clipsToBounds = true
        
        let image = UIImage(named: "Downloadx3.png")?.withRenderingMode(.alwaysTemplate)
        BtnDownload.setImage(image, for: .normal)
        BtnDownload.tintColor = Constants.nearColor
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        NVActivityIndicatorPresenter.sharedInstance.setMessage("Descargando Servicio...")
        ///////Delay////////
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        })
        ///////////////////
        firebaseDataRetriever.getFirebaseServiceDetails(serviceName: TxtPdnName.text!, completion: {
            let obtainedUUID = self.dbManager.getServiceUUID(serviceName: self.TxtPdnName.text!)
            print("El nombre es \(self.TxtPdnName.text!) y la UUID es \(obtainedUUID)")
            self.beaconNotificationManager.enableServiceNotifications(for: BeaconID(UUIDString: obtainedUUID))
            self.delegate?.resfreshTable()
            self.firebaseDataRetriever.getFirebaseServiceStations(serviceName: self.TxtPdnName.text!)
        })
    }
    
}
