//
//  ViewController.swift
//  porrrrrrn
//
//  Created by Masaki Horimoto on 2016/11/24.
//  Copyright © 2016年 Masaki Horimoto. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import StoreKit
import GoogleMobileAds

class ViewController: UIViewController, AVAudioPlayerDelegate, SKStoreProductViewControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var countLabel: UILabel!
    
    let defalutVolume: Float = 0.8
    var playerState = playingState.stop
    var pornPlayer: AVAudioPlayer?
    var count: Int = 0
    
//    let YOUR_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_BARNER_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_INTERSTITIAL_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let TEST_DEVICE_ID = "4b4c24d168acf7171dba5b0000000000" // Enter Test ID here
    let AdMobTest:Bool = true
    let SimulatorTest:Bool = true
    var _interstitial: GADInterstitial?

    //state管理用enum
    enum playingState: Int {
        case stop
        case play
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let bannerView:GADBannerView = getAdBannerView()
        self.view.addSubview(bannerView)
        
        guard let soundURL = getPornSoundFileURL() else {
            fatalError("Failed to soundURL")
        }
        
        do {
            pornPlayer = try AVAudioPlayer(contentsOf: soundURL)    //指定したサウンドファイル数分Playerを作成
        } catch {
            fatalError("Failed to initialize a player.")
        }
        
        guard let pornPlayer = pornPlayer else {
            fatalError("Failed to initialize a player. (player is nil)")
        }
        
        pornPlayer.numberOfLoops = 0   //Loopはしない
        pornPlayer.volume = defalutVolume  //各Playerの再生ボリュームを基準値の0.8にする
        pornPlayer.prepareToPlay()         //再生準備(バッファ読み込み)
        
        countLabel.text = "\(count)"
        
        _interstitial = createAndLoadInterstitial()
        
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
    
    /**
     プロジェクト内に保存したファイル名からURLを作成する
     
     - returns: URLを返す
     */
    func getPornSoundFileURL() -> URL? {
        
        //let pornSoundFileURL: URL?
        let fileName: NSString = "porn"
        
        let encFileName = fileName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        guard let filePath = Bundle.main.url(forResource: encFileName! as String , withExtension: "m4a") else {
            fatalError("Path is nil.")
        }
        
        
        
        
        //let audioPath = URL(fileURLWithPath: filePath)
        
        return filePath
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressPornButton(_ sender: Any) {
        
        playSound()
        
        count += 1
        countLabel.text = "\(count)"
        
    }
    

    
    func playSound() {
        
        switch playerState {
            
        case playingState.stop:
            playerState = playingState.play
            
            guard let pornPlayer = pornPlayer else {
                fatalError("Failed to player.")
            }
            
            pornPlayer.play()
            
        case playingState.play:
            
            guard let pornPlayer = pornPlayer else {
                fatalError("Failed to player.")
            }
            
            pornPlayer.stop()
            pornPlayer.currentTime = 0
            playerState = playingState.stop
            
            playSound()
            
        }
        
        if count != 0 && count % 4 == 0 {
            print("count is \(count)")
            presentInterstitial()
        }
        
    }
    
    /*
     AVAudioPlayerのDelegate関数
     指定された音声ファイルの再生が完了した場合に呼ばれる
     このアプリでは基幹ループの再生完了時のみ呼ばれるように設定している
     */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        print("\(#function) is called!")
        
        playerState = playingState.stop
        
        guard let pornPlayer = pornPlayer else {
            fatalError("Failed to initialize a player. (player is nil)")
        }
        
        pornPlayer.prepareToPlay()         //再生準備(バッファ読み込み)
        
        if count % 4 == 0 {
            presentInterstitial()
        }
        
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
        
        let itunesURL:String = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1029309778"
        let url = URL(string:itunesURL)
        let app:UIApplication = UIApplication.shared
        if #available(iOS 10.0, *) {
            app.open(url!)
        } else {
            app.openURL(url!)
        }
        
    }
    
    @IBAction func pressResetButton(_ sender: Any) {
        
        count = 0
        countLabel.text = "\(count)"
        
        presentInterstitial()
        
    }
    
    fileprivate func createAndLoadInterstitial()->GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: YOUR_INTERSTITIAL_ID)
        interstitial.delegate = self
        let request:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                request.testDevices = [kGADSimulatorID]
            } else {
                request.testDevices = [TEST_DEVICE_ID]
            }
        }
        
        interstitial.load(request)
        
        return interstitial
    }
    
    fileprivate func presentInterstitial() {
        
        guard let interstitial = _interstitial else {
            print ("_interstitial is nil.")
            return
        }
        
        interstitial.present(fromRootViewController: self)
        
    }
    
    @IBAction func pressHowToUse(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController(title:"使い方",
                                                         message: "お友達がプロフェッショナルな発言をした時にポーンボタンを押しましょう。\nドヤった回数を数えると同時に名言の空気感を演出できます。",
                                                         preferredStyle: UIAlertControllerStyle.alert
        )
        
        // Default 複数指定可
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK",
                                                         style: UIAlertActionStyle.default,
                                                         handler:{
                                                            (action:UIAlertAction!) -> Void in
                                                            print("OK")
        })
        
        // AddAction 記述順に反映される
        alert.addAction(defaultAction)
        
        // Display
        present(alert, animated: true, completion: nil)
        
    }
    
}

