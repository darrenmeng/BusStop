
//
//  BusStopData.swift
//  BusStop
//
//  Created by ChiangMengTao on 2015/11/27.
//  Copyright © 2015年 DarrenIT. All rights reserved.
//

import Foundation

class StopData: NSObject {
    
    var waypoints = [Waypoint]()
    
    typealias StopDataCompletionHandler = (StopData?) -> Void
    
    
    //private let url: NSURL?
    private let completionHandler: StopDataCompletionHandler
    
    
    class func  getBusStopJson(completionHandler:StopDataCompletionHandler) {
        
        if let path = NSBundle.mainBundle().pathForResource("BusStop", ofType: "json")
        {  do
        {
            let jsonData = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMapped)
            
            if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            {
                
                
                
                if let persons : NSArray = jsonResult["features"] as? NSArray
                {
                    
                    let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                    
                    dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            AppDelegate.getdelegate().showIndicator()
                            
                        })
                        StopData(completionHandler: completionHandler).jsonToArray(persons)
                        
                        
                    })
                    
                    
                    
                    
                    
                }
            }
            
        }catch let error as NSError {
            print(error.localizedDescription)
            }
        }
        
    }
    
    class Waypoint: Entry {
        var latitude: Double
        var longitude: Double
        
        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
            super.init()
        }
        
        var info: String? {
            set { attributes["bussto"] = newValue }
            get { return attributes["bussto"] }
        }
        
        
        override var description: String {
            return ["lat=\(latitude)", "lon=\(longitude)", super.description].joinWithSeparator(" ")
        }
    }
    
    private init(completionHandler: StopDataCompletionHandler) {
        
        self.completionHandler = completionHandler
    }
    
    private func complete(success success: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.completionHandler(success ? self : nil)
        }
    }
    
    private var waypoint: Waypoint?
    
    private func jsonToArray(jsonArray:NSArray){
        
        for number in jsonArray {
            print(number)
            let geometry = number["geometry"]
            
            print("\(geometry!!["coordinates"])")
            if let coordiates = geometry!!["coordinates"] {
                
                let latitude = coordiates![1].doubleValue
                
                let longitude = coordiates![0] .doubleValue
                waypoint = Waypoint(latitude:latitude, longitude: longitude)
            }
            
            let properties = number["properties"]!
            
            print("\(properties!["bsm_bussto"])")
            
            
            let string = properties!["bsm_bussto"] as! Int
            
            print("\(string)")
            
            waypoint?.attributes["bussto"] = String( properties!["bsm_bussto"]! as! Int)
            waypoint?.attributes["chines"]=properties!["bsm_chines"] as? String
            
            
            print("\(waypoint?.attributes["bussto"])")
            
            if let point = waypoint {
                waypoints.append(point)
                waypoint = nil
            }
        }
        
        if waypoints.count > 0 {
            succeed()
        }else{
            fail()
        }
    }
    
    
    private func fail() { complete(success: false) }
    private func succeed() { complete(success: true) }
    
    
    
    class Entry: NSObject
    {
        var attributes = [String:String]()
        
        
        
        var name: String? {
            set { attributes["chines"] = newValue }
            get { return attributes["chines"] }
        }
        
        
        override var description: String {
            var descriptions = [String]()
            if attributes.count > 0 { descriptions.append("attributes=\(attributes)") }
            
            return descriptions.joinWithSeparator(" ")
        }
    }
    
    
}