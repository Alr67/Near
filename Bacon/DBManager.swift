//
//  DBManager.swift
//  Bacon
//
//  Created by Rafael Lucena Araujo on 16/2/17.
//  Copyright © 2017 Rafael Lucena Araujo. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
    
    static let sharedInstance = DBManager()

    private override init() { //This prevents others from using the default '()' initializer for this class.
        super.init()
    }
    
    /* BEACON DATA MANAGEMANT SECTION. Beacons' data will be managed here, with functions regarding
       storing,updating,deleting PDNs, and obtaining specific data as the Minor, Major, SPName and Notification Text*/
    
    func createNewBeaconIdentity (serviceName: String, serviceUUID: String, logoURL: String) {
    
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderName contains %@", serviceName)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            if(searchResults.isEmpty) {
                //Cretae Entity Instance
                let newIdentity = BeaconIdentifier.init(entity: NSEntityDescription.entity(forEntityName: "BeaconIdentifier", in: getContext())!, insertInto: getContext())
                //And give value to the parameters. nothing else required to be done, since CoreData takes care of add the new instance to the DB
                newIdentity.serviceProviderName = serviceName
                newIdentity.serviceProviderUUID = serviceUUID
                newIdentity.serviceProviderLogo = logoURL
                newIdentity.serviceProviderActivated = true;
                do {
                    try getContext().save()
                }
                catch {
                    print("Error with request: \(error)")
                }
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func createNewBeaconDetails (serviceName: String, serviceMajor: Int32, serviceMinor: Int32, serviceNotification: String, serviceDetail: String) {
        
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderName contains %@", serviceName)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            if(!searchResults.isEmpty) {
                //Create new instance to add it to de DB
                let newDetail = BeaconDetails.init(entity: NSEntityDescription.entity(forEntityName: "BeaconDetails", in: getContext())!, insertInto: getContext())
                //We add each parameter
                newDetail.serviceProviderMajor = serviceMajor
                newDetail.serviceProviderMinor = serviceMinor
                newDetail.serviceProviderNotification = serviceNotification
                newDetail.serviceProviderDetail = serviceDetail
                //And then link it with the relation
                searchResults[0].addToBeaconDetailedInformation(newDetail)
                do {
                    try getContext().save()
                }
                catch {
                    print("Error with request: \(error)")
                }
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func setActiveStatus (serviceName: String, activeService: Bool) {
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderName contains %@", serviceName)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            if(!searchResults.isEmpty) {
                searchResults[0].serviceProviderActivated = activeService
                do {
                    try getContext().save()
                }
                catch {
                    print("Error with request: \(error)")
                }
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func getServiceNotification (serviceUUID: String, serviceMajor: Int32, serviceMinor: Int32) -> String {
        var serviceNotification = "No message found"
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconDetails> = BeaconDetails.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate1 = NSPredicate(format: "beaconGenericInformation.serviceProviderUUID contains %@", serviceUUID)
        let predicate2 = NSPredicate(format: "serviceProviderMajor contains %i", serviceMajor)
        let predicate3 = NSPredicate(format: "serviceProviderMinor contains %i", serviceMinor)
        //Let's merge the predicates
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates:  [predicate1, predicate2, predicate3])
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                serviceNotification = (trans.value(forKey: "serviceProviderNotification") as! String)
            }
        } catch {
            print("Error with request: \(error)")
        }
        return serviceNotification
    }

    
    func getServiceUUID (serviceName: String) -> String {
        var serviceUUID = String();
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderName contains %@", serviceName)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                serviceUUID = (trans.value(forKey: "serviceProviderUUID")) as! String
            }
        } catch {
            print("Error with request: \(error)")
        }
        return serviceUUID
    }
    
    
    func getServiceLogo (serviceUUID: String) -> String {
        var serviceLogo = String();
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderUUID contains %@", serviceUUID)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                serviceLogo = (trans.value(forKey: "serviceProviderLogo")) as! String
            }
        } catch {
            print("Error with request: \(error)")
        }
        return serviceLogo
    }
    
    func getServiceNameLogo (serviceName: String) -> String {
        var serviceLogo = String();
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderName contains %@", serviceName)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                serviceLogo = (trans.value(forKey: "serviceProviderLogo")) as! String
            }
        } catch {
            print("Error with request: \(error)")
        }
        return serviceLogo
    }
    
    func checkIfDownloaded(serviceName: String) -> Bool {
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderName contains %@", serviceName)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            if(searchResults.count >= 1) {
                return true
            }
            else {
                return false
            }
        } catch {
            print("Error with request: \(error)")
        }
        return false
    }
    
    
    func deletePdnInformation(serviceName: String) {
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderName contains %@", serviceName)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            for trans in searchResults as [NSManagedObject] {
                getContext().delete(trans)
            }
            do {
                try getContext().save()
            }
            catch {
                print("Error with request: \(error)")
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    /************************************************************************************/
    
    /* PDN LIST MANAGEMENT SECTION. Here information to be displayed in the Views can be obtained, added, edited and erased. Functions like getting all de Service Providers for the PDN list, add a new PDN or erase it*/
    
    func getAllDownloadedPDN() -> (Array<String>, Array<Bool>){
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BeaconIdentifier")
        //We create an empty Array to store the results
        var definitiveResults = [String]()
        var definitiveState = [Bool]()
        //Pedimos solo el SPN
        fetchRequest.propertiesToFetch = ["serviceProviderName"]

        //We proceed with the fetch Request inside our context
        let searchResults = try! getContext().fetch(fetchRequest)
            
            
        //You need to convert to NSManagedObject to use 'for' loops
        for trans in searchResults as! [NSManagedObject] {
            //We store the string temporarily
            let tempo = trans.value(forKey: "serviceProviderName")
            //And append it to the solution
            definitiveResults.append(tempo as! String)
            
            //repeat for the activated value
            let isActive = trans.value(forKey: "serviceProviderActivated")
            definitiveState.append(isActive as! Bool)
            

        }

        return (definitiveResults, definitiveState)
    }
    

    func getServiceDetail (serviceUUID: String, serviceMajor: Int32, serviceMinor: Int32) -> String{
        var solutionString = String()
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconDetails> = BeaconDetails.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate1 = NSPredicate(format: "beaconGenericInformation.serviceProviderUUID contains %@", serviceUUID)
        let predicate2 = NSPredicate(format: "serviceProviderMajor contains %i", serviceMajor)
        let predicate3 = NSPredicate(format: "serviceProviderMinor contains %i", serviceMinor)
        //Let's merge the predicates
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates:  [predicate1, predicate2, predicate3])
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                solutionString = trans.value(forKey: "serviceProviderDetail") as! String
            }
        } catch {
            print("Error with request: \(error)")
        }
        return solutionString
    }
    
    
    func getServiceName (serviceUUID: String) -> String {
        var serviceName = String();
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconIdentifier> = BeaconIdentifier.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "serviceProviderUUID contains %@", serviceUUID)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                serviceName = (trans.value(forKey: "serviceProviderName")) as! String
            }
        } catch {
            print("Error with request: \(error)")
        }
        return serviceName
    }
    
    
    /************************************************************************************/
    
    /*CONTEXT FUNCTION. Necessary to be able to access the DB */
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    /**********************************************************/
    
    /*func getAllServiceDetails (serviceProvider: String) {
        //We create a FetchRequest, indicating the Entity that we want to fetch
        let fetchRequest: NSFetchRequest<BeaconDetails> = BeaconDetails.fetchRequest()
        //We create the Predicate, where we can specify conditions
        //We have to say which parameter contains which value. Several predicates can be merged
        let predicate = NSPredicate(format: "beaconGenericInformation.serviceProviderName contains %@", serviceProvider)
        //And the we attach the predicate to the fetchRequest
        fetchRequest.predicate = predicate
        
        do {
            //We proceed with the fetch Request inside our context
            let searchResults = try getContext().fetch(fetchRequest)
            
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(trans.value(forKey: "serviceProviderNotification"))")
            }
        } catch {
            print("Error with request: \(error)")
        }
    }*/
    
    
    
}
