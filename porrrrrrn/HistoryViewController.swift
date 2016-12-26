//
//  HistoryViewController.swift
//  porrrrrrn
//
//  Created by Masaki Horimoto on 2016/12/09.
//  Copyright © 2016年 Masaki Horimoto. All rights reserved.
//

import UIKit
import StoreKit
import GoogleMobileAds
import RealmSwift


class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, GADInterstitialDelegate {
    
    //    let YOUR_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_BARNER_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_INTERSTITIAL_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let TEST_DEVICE_ID = "4b4c24d168acf7171dba5b***********" // Enter Test ID here
    let AdMobTest:Bool = true
    let SimulatorTest:Bool = true
    var _interstitial: GADInterstitial?
    
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bannerView:GADBannerView = getAdBannerView()
        self.view.addSubview(bannerView)
        
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.title = "履歴"
        
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
    }
    
    override func viewDidLayoutSubviews() {
        let bannerView:GADBannerView = getAdBannerView()
        historyTableView.frame.size.height -= bannerView.frame.size.height
    }
    
    fileprivate func getAdBannerView() -> GADBannerView {
        var bannerView: GADBannerView = GADBannerView()
        bannerView = GADBannerView(adSize:kGADAdSizeBanner)
        bannerView.frame.origin = CGPoint(x: 0, y: view.frame.height - bannerView.frame.height)
        bannerView.frame.size = CGSize(width: self.view.frame.width, height: bannerView.frame.height)
        bannerView.adUnitID = "\(YOUR_BARNER_ID)"
        bannerView.delegate = self
        bannerView.rootViewController = self
        
        let request:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                request.testDevices = [kGADSimulatorID]
            } else {
                request.testDevices = [TEST_DEVICE_ID]
            }
        }
        
        bannerView.load(request)
        
        return bannerView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let realm = try! Realm()
        let names = realm.objects(historyName.self)
        
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "historyCell")
        
        let realm = try! Realm()
        let names = realm.objects(historyName.self).sorted(byProperty: "number")
        let number = names[indexPath.row].number
        let textLabel = names[indexPath.row].historyName
        
        let countInfoForIndex = realm.objects(pornHistory.self).filter("number = \(number)")
        
        let myCalendar = Calendar.current
        let date = countInfoForIndex.last!.pressDateTime
        let year = myCalendar.component(.year, from: date)
        let month = myCalendar.component(.month, from: date)
        let day = myCalendar.component(.day, from: date)
        let hour = myCalendar.component(.hour, from: date)
        let minute = myCalendar.component(.minute, from: date)
        let second = myCalendar.component(.second, from: date)

        cell.textLabel?.text = textLabel
        cell.detailTextLabel?.text = "\(countInfoForIndex.count - 1) ポーン   \(year)/\(month)/\(day) \(hour):\(minute):\(second)"
        cell.detailTextLabel?.textColor = UIColor.gray
        
        if indexPath.row == names.count - 1 {
            
            cell.textLabel?.text = cell.textLabel?.text?.appending(" (計測中)")
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
        }
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        super.setEditing(editing, animated: animated)
        historyTableView.isEditing = editing
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let realm = try! Realm()
        let names = realm.objects(historyName.self).sorted(byProperty: "number")
        
        if indexPath.row == names.count - 1 {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
        let realm = try! Realm()
        let names = realm.objects(historyName.self).sorted(byProperty: "number")
        let number = names[indexPath.row].number
        
        print("number = \(number)")
        
        let countInfoForIndex = realm.objects(pornHistory.self).filter("number = \(number)")
        
        print("count = \(countInfoForIndex.count - 1)")
        
        try! realm.write() {
            realm.delete(countInfoForIndex)
            let deleteName = names[indexPath.row]
            realm.delete(deleteName)
        }
        
        historyTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)

    }
    
    override func didMove(toParentViewController parent: UIViewController?) {

    }
    

    
}

