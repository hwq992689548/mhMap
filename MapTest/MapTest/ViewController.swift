//
//  ViewController.swift
//  MapTest
//
//  Created by 鲜恬科技 on 2019/9/6.
//  Copyright © 2019 鲜恬科技. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width as CGFloat
let kScreenHeight = UIScreen.main.bounds.size.height as CGFloat

class ViewController: UIViewController {
    var address1: UILabel!
    var address2: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let btn1 = UIButton.init(frame: CGRect.init(x: 100, y: 140, width: 180, height: 50))
        btn1.backgroundColor = UIColor.orange
        btn1.setTitle("地图获取位置", for: UIControl.State.normal)
        btn1.addTarget(self, action: #selector(btn1Action), for: UIControl.Event.touchUpInside)
        self.view.addSubview(btn1)
        
        self.address1  = UILabel.init(frame: CGRect.init(x: 15, y: btn1.frame.maxY + 20, width: self.view.frame.size.width-30, height: 80))
        address1.font = UIFont.boldSystemFont(ofSize: 14)
        address1.textColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        address1.textAlignment = .left
        address1.numberOfLines = 0
        self.view.addSubview(address1)
        
        
        let btn2 = UIButton.init(frame: CGRect.init(x: 100, y: address1.frame.maxY + 60, width: 180, height: 50))
        btn2.backgroundColor = UIColor.brown
        btn2.setTitle("定位", for: UIControl.State.normal)
        btn2.addTarget(self, action: #selector(btn2Action), for: UIControl.Event.touchUpInside)
        self.view.addSubview(btn2)
        
        self.address2  = UILabel.init(frame: CGRect.init(x: 15, y: btn2.frame.maxY + 20, width: self.view.frame.size.width-30, height: 80))
        address2.font = UIFont.boldSystemFont(ofSize: 14)
        address2.textColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        address2.textAlignment = .left
        address2.numberOfLines = 0
        self.view.addSubview(address2)
        
    }
    
    @objc func btn1Action()  {
        let vc = MHMapViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btn2Action(){
        MKLocationCenter.getShareInstance().getUserLocation { (placeMark) in
            print(placeMark)
            let lat  = placeMark.location?.coordinate.latitude ?? 0
            let lng  = placeMark.location?.coordinate.longitude ?? 0
            let tt = ((placeMark.addressDictionary!["FormattedAddressLines"] as! NSArray)[0] as! String)
            self.address2.text = String(format: " lat=%lf\n lng=%lf\n %@", lat, lng, tt)
        }
    }
    
}


extension ViewController: MHMapViewControllerDelegate {
    func didSelectMapAddress(address: String) {
        self.address1.text = address
    }
}
