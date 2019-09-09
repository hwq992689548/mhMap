//
//  MHMapViewController.swift
//  MapTest
//
//  Created by 鲜恬科技 on 2019/9/7.
//  Copyright © 2019 鲜恬科技. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MHMapViewControllerDelegate: NSObjectProtocol {
    func didSelectMapAddress(address: String);
}
class MHMapViewController: UIViewController {
    var delegate: MHMapViewControllerDelegate!
    var mapView: MKMapView!
    var locationManager:CLLocationManager!
    var search: AMapSearchAPI!
    
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    
    var showAllFlag: Bool = false //是否展开
    var customView: UIView!  //用来装载地图
    var showAllBtn: UIButton! //展开按钮
    var showFlag: Bool = false
    
    var searchTextField: UITextField!
    var centerPointImgView: UIImageView!  //中间用来定位的point图片
    //var geoCoder: CLGeocoder!  //反解析出地址 根据定位解析出中文地址
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.view.backgroundColor = UIColor.white
        self.locationManager = CLLocationManager.init()
        self.locationManager.requestWhenInUseAuthorization()
        
        self.mapView = MKMapView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight/2))
        self.mapView.mapType = MKMapType.standard
        self.mapView.delegate = self
        self.mapView.userTrackingMode = .follow
        self.view.addSubview(self.mapView)
        
        //可活动的父视图 展开与收缩
        self.customView = UIView.init(frame: CGRect.init(x: 0, y: kScreenHeight/2, width: kScreenWidth, height: kScreenHeight/2))
        self.customView.backgroundColor = UIColor.white
        self.view.addSubview(self.customView)
        
        self.createTableHeaderView()  //展开与收缩按钮
        
        //列表
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: 40, width: kScreenWidth, height: self.customView.frame.size.height-40), style: .plain)
        self.tableView.register(MKSearchTableCell.self , forCellReuseIdentifier: "MKSearchTableCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.white
        self.customView.addSubview(self.tableView)
        
        self.tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 0.01))
        self.tableView.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 0.01))
        
         self.createNavigationBack()  //搜索框
        
        self.centerPointImgView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 72))
        self.centerPointImgView.image = UIImage.init(named: "greenPin")
        self.centerPointImgView.center = CGPoint.init(x: self.mapView.frame.size.width/2, y: self.mapView.frame.size.height/2 + 24)
        self.centerPointImgView.contentMode = .scaleAspectFit
        self.mapView.addSubview(self.centerPointImgView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        if self.mapView != nil {
            self.mapView.removeFromSuperview()
            self.mapView = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.mapView != nil  {
            self.mapView.showsUserLocation = true
            self.btn2Action()
        }
    }
    
    //返回键 + 搜索框
    func createNavigationBack()  {
        let margintop = kScreenHeight >= 812 ? 44 : 30 as CGFloat
        let backBtn = UIButton.init(frame: CGRect.init(x: 15, y: margintop, width: 50, height: 50))
        backBtn.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        backBtn.setTitle("返回", for: UIControl.State.normal)
        backBtn.setTitle("返回", for: UIControl.State.highlighted)
        backBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
        backBtn.setTitleColor(UIColor.black, for: UIControl.State.highlighted)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        backBtn.addTarget(self, action: #selector(backBtnAction), for: UIControl.Event.touchUpInside)
        backBtn.layer.cornerRadius = 25
        backBtn.layer.masksToBounds = true
        self.view.addSubview(backBtn)
        
        //搜索框
        self.searchTextField = UITextField.init(frame: CGRect.init(x: 0, y: margintop, width: kScreenWidth - 150.0, height: 50))
        self.searchTextField.backgroundColor = UIColor.white
        self.searchTextField.textColor = UIColor.darkGray
        self.searchTextField.font = UIFont.systemFont(ofSize: 14)
        self.searchTextField.textAlignment = .left
        self.searchTextField.placeholder = "搜索"
        self.searchTextField.leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 15, height: 15))
        self.searchTextField.leftViewMode = .always
        self.searchTextField.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        self.searchTextField.layer.shadowColor = UIColor.darkGray.cgColor
        self.searchTextField.layer.shadowRadius = 6
        self.searchTextField.layer.shadowOpacity = 0.5
        self.searchTextField.center = CGPoint.init(x: kScreenWidth/2, y: margintop + 25)
        self.view.addSubview(self.searchTextField)
        
        //确定按钮
        let confirmBtn = UIButton.init(frame: CGRect.init(x: kScreenWidth - 65, y: margintop, width: 50, height: 50))
        confirmBtn.backgroundColor = UIColor.blue
        confirmBtn.setTitle("搜索", for: UIControl.State.normal)
        confirmBtn.setTitle("搜索", for: UIControl.State.highlighted)
        confirmBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        confirmBtn.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        confirmBtn.layer.cornerRadius = 25
        confirmBtn.layer.masksToBounds = true
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(confirmBtn)
    }
    
   @objc func backBtnAction()  {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBarView()  {
        let vv = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 45))
        vv.backgroundColor = UIColor.white
        self.view.addSubview(vv)
    }
    
    @objc func confirmBtnAction() {
        let txt = self.searchTextField.text
        if txt != "" {
            self.goSearchByKeyword(keyWord: txt!)
        }
    }
    
    //展开  tableView的顶部视图
    func createTableHeaderView()  {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 40))
        headerView.backgroundColor = UIColor.white
        
        self.showAllBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: headerView.frame.height))
        self.showAllBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        self.showAllBtn.setTitleColor(UIColor.gray, for: UIControl.State.highlighted)
        self.showAllBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        if self.showAllFlag == true  {
            self.showAllBtn.setTitle("收起", for: UIControl.State.normal)
            self.showAllBtn.setTitle("收起", for: UIControl.State.highlighted)
        }else{
            self.showAllBtn.setTitle("展开", for: UIControl.State.normal)
            self.showAllBtn.setTitle("展开", for: UIControl.State.highlighted)
        }
        self.showAllBtn.addTarget(self, action: #selector(showAllBtnAction), for: UIControl.Event.touchUpInside)
        headerView.addSubview(self.showAllBtn)
        let lineView = UIView.init(frame: CGRect.init(x: 0, y: headerView.frame.height - 1, width: kScreenWidth, height: 1))
        lineView.backgroundColor = UIColor.init(red: 244.0/255, green: 244.0/255, blue: 244.0/255, alpha: 1)
        headerView.addSubview(lineView)
        self.customView.addSubview(headerView)
    }
    
    //MARK: - 展开与收起动作
    @objc func showAllBtnAction(){
        self.showFlag = !self.showFlag
        var btnTitle = ""
        if self.showFlag == true {
            //展开
            btnTitle = "收起"
            let marginTop = 130 as CGFloat //展开后距离顶端
            UIView.animate(withDuration: 0.24) {
                self.customView.frame = CGRect.init(x: 0, y: marginTop, width: kScreenWidth, height: kScreenHeight - marginTop)
                self.tableView.frame = CGRect.init(x: 0, y: 40, width: kScreenWidth, height: self.customView.frame.size.height - 40)
            }
        }else{
            //收缩
            btnTitle = "展开"
            UIView.animate(withDuration: 0.24) {
                self.customView.frame = CGRect.init(x: 0, y: kScreenHeight/2, width: kScreenWidth, height: kScreenHeight/2)
                self.tableView.frame = CGRect.init(x: 0, y: 40, width: kScreenWidth, height: self.customView.frame.size.height - 40)
            }
        }
        self.showAllBtn.setTitle(btnTitle, for: UIControl.State.normal)
        self.showAllBtn.setTitle(btnTitle, for: UIControl.State.highlighted)
    }
    
    //点击搜索
    @objc func btn2Action(){
        if self.search == nil {
            self.search = AMapSearchAPI.init()
            self.search.delegate = self
        }
        self.goSearchByKeyword(keyWord: "西丽二村")
    }
    
    //MARK: - 前往搜索
    @objc func goSearchByKeyword(keyWord: String) {
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = keyWord
        request.requireExtension = true
        //request.city = "广东"
        //request.cityLimit = true
        request.requireSubPOIs = true
        self.search.aMapPOIKeywordsSearch(request)
    }
}

//MARK: - 地图代理
extension MHMapViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.coordinate)
    }
    
    //拖动地图松开后
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("拖动地图松开后")
        print(mapView.centerCoordinate)
        //中间pin的小动画
        UIView.animate(withDuration: 0.36, animations: {
            UIView.animateKeyframes(withDuration: 0.18, delay: 0, options: UIView.KeyframeAnimationOptions.overrideInheritedOptions, animations: {
                self.centerPointImgView.center.y = self.mapView.frame.size.height/2 + 24 - 15
            }, completion: nil)
            UIView.animateKeyframes(withDuration: 0.18, delay: 0.18, options: UIView.KeyframeAnimationOptions.overrideInheritedOptions, animations: {
                self.centerPointImgView.center.y = self.mapView.frame.size.height/2 + 24
            }, completion: nil)
        }, completion: nil)
        
        let tempPoint = AMapGeoPoint.location(withLatitude: CGFloat(mapView.centerCoordinate.latitude), longitude: CGFloat(mapView.centerCoordinate.longitude))
        self.getPOIByLocation(tmpLocation: tempPoint!)
    }
    
    
    func getPOIByLocation(tmpLocation: AMapGeoPoint)  {
        let request = AMapPOIKeywordsSearchRequest()
        request.requireExtension = true
        request.requireSubPOIs = true
        request.location = tmpLocation
        request.page = 1 //页码  可以分页获取 这里只取第一页 20条数据
        self.search.aMapPOIKeywordsSearch(request)
        //可以添加等待指示器  需要一点时间获取poi
    }
}

//MARK: - 搜索代理
extension MHMapViewController: AMapSearchDelegate {
    //MARK: -
    //回调方法中把poi搜到的地址存到数组中 刷新tableview即可
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.pois.count == 0 {
            return
        }
        self.dataArray.removeAllObjects()
        self.dataArray.addObjects(from: response.pois)
        
        if self.dataArray.count > 0 {
            let firstObj = self.dataArray[0] as! AMapPOI
            print(firstObj.address as Any)
        }
        self.tableView.reloadData()
    }
}


//MARK: - tableView delegate
extension MHMapViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 34
    }
}

extension MHMapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MKSearchTableCell", for: indexPath) as! MKSearchTableCell
        if self.dataArray.count > indexPath.row {
            let poi = self.dataArray[indexPath.row] as! AMapPOI
            cell.titleLab.text = String(format: "%@", poi.name)
            cell.subTitleLab.text = String(format: "%@%@%@%@", poi.province, poi.city, poi.district, poi.address)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.dataArray.count > indexPath.row {
            let model = self.dataArray[indexPath.row] as! AMapPOI
            let vc = MHSelectViewController()
            vc.poiModel = model
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            self.present(vc , animated: false , completion: nil)
        }
    }
}



//MARK: - 自定义cell
class MKSearchTableCell: UITableViewCell {
    var kScreenWidth = UIScreen.main.bounds.size.width
    var kScreenHeight = UIScreen.main.bounds.size.height
    
    var titleLab: UILabel!
    var subTitleLab: UILabel!
    var lineView: UIView!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleLab = UILabel.init(frame: CGRect.init(x: 15, y: 10, width: kScreenWidth-30, height: 24))
        self.titleLab.font = UIFont.systemFont(ofSize: 14)
        self.titleLab.textColor = UIColor.black
        self.contentView.addSubview(self.titleLab)
        
        self.subTitleLab = UILabel.init(frame: CGRect.init(x: 15, y: self.titleLab.frame.maxY, width: kScreenWidth-30, height: 20))
        self.subTitleLab.font = UIFont.systemFont(ofSize: 12)
        self.subTitleLab.textColor = UIColor.gray
        self.contentView.addSubview(self.subTitleLab)
        
        self.lineView = UIView.init(frame: CGRect.init(x: 0, y: 59, width: kScreenWidth, height: 1))
        self.lineView.backgroundColor = UIColor.init(red: 244.0/255, green: 244.0/255, blue: 244.0/255, alpha: 1)
        self.contentView.addSubview(lineView)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MHMapViewController: MHSelectViewControllerDelegate {
    func didConfirmMapAddress(address: String) {
        self.delegate?.didSelectMapAddress(address: address)
        self.navigationController?.popViewController(animated: true)
    }
}
