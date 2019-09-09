//
//  MHSelectViewController.swift
//  MapTest
//
//  Created by 鲜恬科技 on 2019/9/9.
//  Copyright © 2019 鲜恬科技. All rights reserved.
//

import UIKit

protocol MHSelectViewControllerDelegate: NSObjectProtocol {
    func didConfirmMapAddress(address: String);
}
class MHSelectViewController: UIViewController {
    var delegate: MHSelectViewControllerDelegate!
    var content_Height: CGFloat = 280
    var contentView: UIView!
    var bkgBtnView: UIButton!
 
    var poiModel: AMapPOI!
    var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.bkgBtnView = UIButton.init(type: UIButton.ButtonType.custom)
        self.bkgBtnView.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        self.bkgBtnView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.view.addSubview(self.bkgBtnView)
        
        self.contentView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth-80, height: content_Height))
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
        self.contentView.center = CGPoint.init(x: kScreenWidth/2, y: kScreenHeight/2)
        self.view.addSubview(self.contentView)
        
        let titleLab = UILabel.init(frame: CGRect.init(x: 15, y: 8, width: self.contentView.frame.size.width-30, height: 40))
        titleLab.font = UIFont.boldSystemFont(ofSize: 14)
        titleLab.textColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        titleLab.textAlignment = .left
        titleLab.numberOfLines = 0
        titleLab.text = String(format: "%@%@%@", self.poiModel?.province ?? "", self.poiModel?.city ?? "", self.poiModel?.district ?? "")
        self.contentView.addSubview(titleLab)
        
        self.textView = UITextView.init(frame: CGRect.init(x: 15, y: titleLab.frame.maxY, width: self.contentView.frame.size.width - 30, height: self.contentView.frame.size.height-titleLab.frame.maxY-60))
        self.textView.backgroundColor = UIColor.init(red: 244.0/255, green: 244.0/255, blue: 244.0/255, alpha: 1)
        self.textView.font = UIFont.systemFont(ofSize: 14)
        self.textView.textColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.textView.layer.cornerRadius = 4
        self.textView.layer.masksToBounds = true
        self.textView.contentInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        self.contentView.addSubview(self.textView)
        
        self.textView.text = String(format: "%@%@", self.poiModel?.address ?? "", self.poiModel?.name ?? "")
        
        
        let cancelBtn = UIButton.init(frame: CGRect.init(x: 0, y: self.contentView.frame.size.height-50, width: self.contentView.frame.size.width/2, height: 40))
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.setTitle("取消", for: UIControl.State.normal)
        cancelBtn.setTitle("取消", for: UIControl.State.highlighted)
        cancelBtn.setTitleColor(UIColor.red, for: UIControl.State.normal)
        cancelBtn.setTitleColor(UIColor.red, for: UIControl.State.highlighted)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(cancelBtn)
        
        let confirmBtn = UIButton.init(frame: CGRect.init(x: self.contentView.frame.size.width/2, y: self.contentView.frame.size.height-50, width: self.contentView.frame.size.width/2, height: 40))
        confirmBtn.backgroundColor = UIColor.white
        confirmBtn.setTitle("确定", for: UIControl.State.normal)
        confirmBtn.setTitle("确定", for: UIControl.State.highlighted)
        confirmBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        confirmBtn.setTitleColor(UIColor.blue, for: UIControl.State.highlighted)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(confirmBtn)
        
        
    }
    
    //取消
    @objc func cancelBtnAction()  {
        self.bkgBtnView.alpha = 1
        self.contentView.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.bkgBtnView.alpha = 0
            self.contentView.alpha = 0
        }) { (flag) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    //确定
    @objc func confirmBtnAction()  {
        let headerStr = String(format: "%@%@%@", self.poiModel?.province ?? "", self.poiModel?.city ?? "", self.poiModel?.district ?? "")  //省市区
        let detailStr = self.textView.text ?? "" //手动补的信息
        self.delegate?.didConfirmMapAddress(address: String(format: "%@%@", headerStr, detailStr))
        self.cancelBtnAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
