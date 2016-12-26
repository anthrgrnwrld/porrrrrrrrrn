//
//  AboutViewController.swift
//  porrrrrrn
//
//  Created by Masaki Horimoto on 2016/12/05.
//  Copyright © 2016年 Masaki Horimoto. All rights reserved.
//

import UIKit
import StoreKit
import GoogleMobileAds

class AboutViewController: UIViewController, SKStoreProductViewControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    //    let YOUR_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_BARNER_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_INTERSTITIAL_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let TEST_DEVICE_ID = "4b4c24d168acf7171dba5b***********" // Enter Test ID here
    let AdMobTest:Bool = true
    let SimulatorTest:Bool = true
    var _interstitial: GADInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bannerView:GADBannerView = getAdBannerView()
        self.view.addSubview(bannerView)
        
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
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
    
    @IBAction func pressOtherAppButton(_ sender: Any) {
        let productViewController = SKStoreProductViewController()
        productViewController.delegate = self
        
        self.present( productViewController, animated: true, completion: {() -> Void in
            
            let productID = "1018825942" // 開発者ID
            let parameters:Dictionary = [SKStoreProductParameterITunesItemIdentifier: productID]
            productViewController.loadProduct( withParameters: parameters, completionBlock: {(Bool, NSError) -> Void in
                // 読み込み完了またはエラーのときの処理
                // ...
            })
        })
    }
    
    /**
     SKStoreProductViewControllerにてキャンセルボタンが押された時の処理
     */
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        dismiss( animated: true, completion: nil);
    }
    

    @IBAction func pressReviewButton(_ sender: Any) {
        
        let itunesURL:String = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1180667533"
        let url = URL(string:itunesURL)
        let app:UIApplication = UIApplication.shared
        if #available(iOS 10.0, *) {
            app.open(url!)
        } else {
            app.openURL(url!)
        }
        
    }
}
