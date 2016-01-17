//
//  ViewController.swift
//  BusStop
//
//  Created by ChiangMengTao on 2015/11/27.
//  Copyright © 2015年 DarrenIT. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate
{
    
    
    var text = String()
    
    var locationArray = [Int]()
    
    var location : CLLocationManager!{
        
        didSet{
            location.delegate = self;
            
            
            
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .Standard
            mapView.delegate = self
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        location = CLLocationManager();
        
        StopData.getBusStopJson({
            if let busWay = $0 {
                
                print(busWay.waypoints)
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0), { () -> Void in
                    self.handleWayPoint(busWay.waypoints)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        AppDelegate.getdelegate().hideIndicator()
                        //詢問使用者是否同意給APP定位功能
                        self.location.requestWhenInUseAuthorization();
                        //開始接收目前位置資訊
                        self.location.startUpdatingLocation();
                        self.location.distanceFilter = CLLocationDistance(10);
                    })
                })
            }
        })
        
        
        
        
        
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //取得目前的座標位置
        let c = locations[0]
        let nowLocation = CLLocationCoordinate2D(latitude: c.coordinate.latitude, longitude: c.coordinate.longitude);
        //將map中心點定在目前所在的位置
        //span是地圖zoom in, zoom out的級距
        let _span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005);
        self.mapView.setRegion(MKCoordinateRegion(center: nowLocation, span: _span), animated: true);
        self.mapView.showsUserLocation = true
    }
    
    func handleWayPoint(wayPoint: [ StopData.Waypoint]) {
        mapView.addAnnotations(wayPoint)
        mapView.showAnnotations(wayPoint, animated:true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        
        
        let detailButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
        
        // 表示不自訂藍點
        if annotation is MKUserLocation {
            
            return nil
        }
        
        if view == nil {
            
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view?.canShowCallout = true
            view!.rightCalloutAccessoryView = detailButton
        }else{
            view?.annotation = annotation
        }
        
        view!.image = UIImage(named: "transport80.png")
        
        
        return view
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWaypointPopoverWidth:CGFloat = 320
    }
    
    
}

