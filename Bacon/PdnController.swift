//
//  PdnController.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 13/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit
import CoreData

class PdnController: UIViewController {
    
    var pdnList = [String]()
    var pdnState = [Bool]()
    let dbManager = DBManager.sharedInstance
    let beaconNotificationManager = BeaconNotificationManager.sharedInstance
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        (pdnList, pdnState) = dbManager.getAllDownloadedPDN()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        (pdnList, pdnState) = dbManager.getAllDownloadedPDN()
        self.tableView.reloadData()
        
        self.navigationController?.navigationBar.barTintColor = Constants.nearColor
        self.tabBarController?.tabBar.barTintColor = Constants.nearColor
    }
    
}


extension PdnController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pdnList.count
    }
    
    //Para eliminar Service
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! PdnCellTableViewCell
            let modifiedPdnUUID = dbManager.getServiceUUID(serviceName: cell.getCellName())
            
            self.beaconNotificationManager.disableServiceNotifications(for: BeaconID(UUIDString: modifiedPdnUUID))
            dbManager.deletePdnInformation(serviceName: cell.getCellName())
            pdnList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //Estilo de la celda
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 137.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PdnCell", for: indexPath) as! PdnCellTableViewCell
        
        cell.contentView.backgroundColor = UIColor.clear
        
        /*let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0,y: 10,width: self.view.frame.size.width,height: 120))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1,height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)*/

        cell.TxtPdnName?.text = pdnList[indexPath.item]
        cell.SwtPdnActive.setOn(pdnState[indexPath.item], animated: true)
        
        let urlString = dbManager.getServiceNameLogo(serviceName: pdnList[indexPath.item])
        let urlImage = URL(string: urlString)
        cell.ImgServiceLogo.sd_setImage(with: urlImage)
        
        return cell
    }
    


}
