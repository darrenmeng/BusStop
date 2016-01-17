
//
//  MKBusStopPoint.swift
//  BusStop
//
//  Created by ChiangMengTao on 2015/12/5.
//  Copyright © 2015年 DarrenIT. All rights reserved.
//

import Foundation
import MapKit

extension StopData.Waypoint : MKAnnotation{
    
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
    }
    
    var title: String? { return name }
    

    var subtitle: String? {
        
        print("\(info)")
        return info }


}


