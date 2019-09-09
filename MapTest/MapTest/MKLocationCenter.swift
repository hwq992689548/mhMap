//
//  MKLocationCenter.swift
//  MapTest
//
//  Created by 鲜恬科技 on 2019/9/7.
//  Copyright © 2019 鲜恬科技. All rights reserved.
//  不带mapview的  只定获取定位

import UIKit
import MapKit

typealias LocationCallBack = (CLPlacemark) -> Void
class MKLocationCenter: NSObject {
    var locationCallBack: LocationCallBack!
    var locationManager: CLLocationManager!
    var resultDict: NSDictionary!
    
    //单例
    private static var sharedInstance: MKLocationCenter?
    class func getShareInstance() -> MKLocationCenter {
        guard let instance = sharedInstance else {
            sharedInstance = MKLocationCenter()
            return sharedInstance!
        }
        return instance
    }
    class func destroy() {
        sharedInstance = nil
    }
    
    //MARK: -  开始定位
    func getUserLocation(complete: @escaping LocationCallBack) {
        self.locationManager = CLLocationManager.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 100
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation() //开始定位
        self.locationCallBack = complete
    }
}


extension MKLocationCenter: CLLocationManagerDelegate {
    //MARK: -  定位回调代理
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currLocation = locations.last
        if currLocation == nil {
            return
        }
        let geoCoder = CLGeocoder.init() //反向解析，根据及纬度反向解析出地址
        geoCoder.reverseGeocodeLocation(currLocation!) { (placemarks, error) in
            for place in (placemarks?.enumerated())! {
                let resultDict = place.element //place.element.addressDictionary! as NSDictionary
                if self.locationCallBack != nil {
                    self.locationCallBack(resultDict)
                }
            }
        }
    }
    
    //MARK: -  检测应用是否开启定位服务
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        let err = error as! CLError
        switch err.code {
        case .denied:
            let alertController = UIAlertController.init(title: "当前定位服务不可用", message: "请到“设置->隐私->定位服务”中开启定位", preferredStyle: .alert)
            let action = UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default) { (alertAction) in
                
            }
            alertController.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            break;
        case .locationUnknown:
            ()
        default:
            ()
        }
    }
}
