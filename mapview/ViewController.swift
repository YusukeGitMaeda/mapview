//
//  ViewController.swift
//  mapview
//
//  Created by 前田 雄亮 on 2015/06/21.
//  Copyright (c) 2015年 前田 雄亮. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate/*, NSURLSession*/ {
    
    var myMapView: MKMapView!
    var myLocationManager: CLLocationManager!
    
    var hotpepperLongitude: Double!
    var hotpepperLatitude: Double!
    var shopName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = 100.0
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.NotDetermined) {
            
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization();
        }
        
        myLocationManager.startUpdatingLocation()
        
        myMapView = MKMapView()
        myMapView.frame = self.view.bounds
        myMapView.delegate = self
        
        // MapViewをViewに追加.
        self.view.addSubview(myMapView)
        
        // 中心点の緯度経度.
        let myLat: CLLocationDegrees = 34.6983328
        let myLon: CLLocationDegrees = 135.4907778
        let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLat, myLon) as CLLocationCoordinate2D
        
        // 縮尺.
        let myLatDist : CLLocationDistance = 100
        let myLonDist : CLLocationDistance = 100
        
        // Regionを作成.
        let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, myLatDist, myLonDist);
        
        // MapViewに反映.
        myMapView.setRegion(myRegion, animated: true)
        
        // ピンを生成.
        var myPin: MKPointAnnotation = MKPointAnnotation()
        
        // 経度、緯度.
        let myLatitude: CLLocationDegrees = 34.6983328
        let myLongitude: CLLocationDegrees = 135.4907778
        
        // 座標を設定.
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLatitude, myLongitude)
        myPin.coordinate = center
        
        // タイトルを設定.
        myPin.title = "なう"
        
        // サブタイトルを設定.
        myPin.subtitle = "お腹すいた"
        
        
        // MapViewにピンを追加.
        myMapView.addAnnotation(myPin)
        
        getDate()
        
    }
    
    // GPSから値を取得した際に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.myMapView.setRegion(region, animated: true)
    }
    
    // Regionが変更した時に呼び出されるメソッド.
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("regionDidChangeAnimated")
    }
    
    // 認証が変更された時に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedWhenInUse:
            println("AuthorizedWhenInUse")
        case .AuthorizedAlways:
            println("Authorized")
        case .Denied:
            println("Denied")
        case .Restricted:
            println("Restricted")
        case .NotDetermined:
            println("NotDetermined")
        default:
            println("etc.")
        }
    }
    
    //APIデータの取得処理
    
    func getDate(){
        println("取得なう")
        // use NSURLSession
        var url: NSURL = NSURL(string:"http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=7a07e3ec42b914d4&format=json&lat=35.6800079345703&lng=139.768936157227")!
        var myRequest = NSMutableURLRequest(URL: url)
        myRequest.HTTPMethod = "GET"
        /*
        var task = NSURLSession.sharedSession().dataTaskWithRequest(myRequest, completionHandler: { data, response, error in
            if (error == nil) {
                //正常終了、レスポンスはdataに
                println(NSString(data:data, encoding:NSUTF8StringEncoding))
            } else {
                println(error)
            }
        })
        task.resume()
        */
        let connection :NSURLConnection = NSURLConnection(request: myRequest, delegate: self, startImmediately: false)!
        
        NSURLConnection.sendAsynchronousRequest(myRequest, queue: NSOperationQueue.mainQueue(), completionHandler: response)
    }
    
    
    // 取得したAPIデータの処理
    func response(res: NSURLResponse!, data: NSData!, error: NSError!){
        /*
        let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data,
        options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
        //let tourspots:NSDictionary = json.objectForKey("tourspots") as! NSDictionary
        let names:NSDictionary = json.objectForKey("[tourspots]") as! NSDictionary
        let name1:NSArray = names.objectForKey("name.written") as! NSArray
        */
        
        
        
        let json = JSON(data: data)
        for i in 0...5 {
            if let stringdata = json["results"]["shop"][i]["name"].string{
                shopName = stringdata
                NSLog(stringdata)
            }
            
            
            if var longitude : String = json["results"]["shop"][i]["lng"].string, var latitude : String = json["results"]["shop"][i]["lat"].string {
            hotpepperLatitude = atof(latitude)
            hotpepperLongitude = atof(longitude)
            println("経度\(longitude), 緯度\(latitude)")
            
            }
        
            makeTourspotsPins(hotpepperLatitude!,longitude: hotpepperLongitude!)
        }
        
        
    }
    
    
    //mapにピンを立てる
    func makeTourspotsPins(latitude:Double, longitude:Double){
        
        var hotpepperPin :MKPointAnnotation = MKPointAnnotation()
        let pinLongitude :CLLocationDegrees = longitude
        let pinLatitude :CLLocationDegrees = latitude 
        
        let coordinate :CLLocationCoordinate2D = CLLocationCoordinate2DMake(pinLatitude, pinLongitude) //let
        
        hotpepperPin.coordinate = coordinate
        //hotpepperPin.title = hotpepperName
        hotpepperPin.title = shopName
            myMapView.addAnnotation(hotpepperPin)
        
        
    }
    

}


