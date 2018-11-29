//
//  DetailedNotificationController.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 19/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView

class DetailedNotificationController: UIViewController, ESTBeaconManagerDelegate, BeaconNotificationManagerDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var TemperatureLabel: UILabel!
    @IBOutlet weak var NotificationLabel: UILabel!
    @IBOutlet weak var DetailLabel: UILabel!
    @IBOutlet weak var LogoImage: UIImageView!
    @IBOutlet weak var InternetLabel: UILabel!
    @IBOutlet weak var HeaderBackground: UIView!
    @IBOutlet weak var RoundedBackground: UIView!
    
    let dbManager = DBManager.sharedInstance
    let beaconNotificationManager = BeaconNotificationManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BeaconNotificationManager.sharedInstance.delegate = self
        
        var titleView : UIImageView
        // set the dimensions you want here
        titleView = UIImageView(frame:CGRect(x:0, y:0, width:10, height:30))
        // Set how do you want to maintain the aspect
        titleView.contentMode = .scaleAspectFit
        titleView.image = UIImage(named: "Cabecera.PNG")
        
        self.navigationController?.navigationBar.topItem?.titleView = titleView

        
        //self.HeaderBackground.frame = CGRect(x: -572, y: 557, width: 1518, height: 744)
        self.HeaderBackground.backgroundColor = Constants.nearColor
        self.HeaderBackground.center = self.view.center
        
        self.RoundedBackground.backgroundColor = Constants.nearColor
        self.RoundedBackground.layer.cornerRadius = self.RoundedBackground.frame.size.width/2
        self.RoundedBackground.clipsToBounds = true
        self.HeaderBackground.sendSubview(toBack: self.RoundedBackground)
        
        self.LogoImage.layer.cornerRadius = self.LogoImage.frame.size.width/2
        self.LogoImage.clipsToBounds = true

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = Constants.nearColor
        self.tabBarController?.tabBar.barTintColor = Constants.nearColor
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //Waiting animation
        let size = CGSize(width: 60, height: 60)
        startAnimating(size,message: "Buscando Beacons...", type: NVActivityIndicatorType.ballScaleRippleMultiple);
        //Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            self.stopAnimating()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func placesNearBeacon(beacon: CLBeacon) {
        NotificationLabel?.text = dbManager.getServiceNotification(serviceUUID: beacon.proximityUUID.uuidString, serviceMajor: Int32(beacon.major), serviceMinor: Int32(beacon.minor))
        
        NameLabel?.text = dbManager.getServiceName(serviceUUID: beacon.proximityUUID.uuidString)
        
        DetailLabel?.text = dbManager.getServiceDetail(serviceUUID: beacon.proximityUUID.uuidString, serviceMajor: Int32(beacon.major), serviceMinor: Int32(beacon.minor))
        
        let urlString = dbManager.getServiceLogo(serviceUUID: beacon.proximityUUID.uuidString)
        let urlImage = URL(string: urlString)
        LogoImage.sd_setImage(with: urlImage)
        
        TemperatureLabel?.text = "\(beaconNotificationManager.getTemperature().roundTo(places: 1)) ºC"
        
        stopAnimating()
    }
    
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

