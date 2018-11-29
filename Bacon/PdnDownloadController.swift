//
//  PdnDownloadController.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 13/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class PdnDownloadController: UIViewController, DownloadCellControllerDelegate, NVActivityIndicatorViewable {
    
    let firebaseDataRetriever = FirebaseDataRetriever.sharedInstance
    var serviceList = [String]()
    var serviceLogoList = [String]()
    let dbManager = DBManager.sharedInstance

    
    
    var myGroup = DispatchGroup()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableFooterView = UIView(frame: .zero)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resfreshTable()
        
        self.navigationController?.navigationBar.barTintColor = Constants.nearColor
        self.tabBarController?.tabBar.barTintColor = Constants.nearColor

    }
    
}


extension PdnDownloadController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PdnDownloadCell", for: indexPath) as! PdnDownloadCellTableViewCell
        
        cell.contentView.backgroundColor = UIColor.clear
        
        /*let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0,y: 10,width: self.view.frame.size.width,height: 120))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1,height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)*/
        
        let serviceName = serviceList[indexPath.item]
        
        let urlString = serviceLogoList[indexPath.item]
        let urlImage = URL(string: urlString)
        cell.ImgLogo.sd_setImage(with: urlImage)
        
        
        
        cell.TxtPdnName?.text = serviceName
        
        cell.delegate = self
        
        return cell
    }
    
    
    
    func resfreshTable() {
        serviceList = [String]()
        serviceLogoList = [String]()
        let size = CGSize(width: 60, height: 60)
        startAnimating(size,message: "Cargando lista...", type: NVActivityIndicatorType.lineScale);
        ///////Delay////////
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
            self.stopAnimating()
        })
        ///////////////////
        firebaseDataRetriever.getFirebaseServiceList(completion: {
            serviceArray -> Void in
            for serviceName in serviceArray {
                self.myGroup.enter()
                if(!self.dbManager.checkIfDownloaded(serviceName: serviceName)) {
                    self.serviceList.append(serviceName)
                    self.myGroup.enter()
                    self.firebaseDataRetriever.getFirebaseServiceLogo(serviceName: serviceName, completion: {
                        serviceURL -> Void in
                        self.serviceLogoList.append(serviceURL)
                        self.myGroup.leave()
                    })
                    
                }
                self.myGroup.leave()
            }
            self.myGroup.notify(queue: .main) {
                print("Finished all requests.")
                self.tableView.reloadData()
                self.stopAnimating();
            }
        })
        self.tableView.reloadData()
        
    }

    
}

