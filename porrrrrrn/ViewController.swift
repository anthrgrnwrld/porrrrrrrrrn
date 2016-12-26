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
import RealmSwift

class ViewController: UIViewController, AVAudioPlayerDelegate, SKStoreProductViewControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    
    let defalutVolume: Float = 0.8
    var playerState = playingState.stop
    var pornPlayer: AVAudioPlayer?
    var count: Int = 0
    var number: Int = 0
    
//    let YOUR_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_BARNER_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let YOUR_INTERSTITIAL_ID = "ca-app-pub-3530000000000000/0123456789"  // Enter Ad's ID here
    let TEST_DEVICE_ID = "4b4c24d168acf7171dba5b***********" // Enter Test ID here
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
        
        _interstitial = createAndLoadInterstitial()
        
        self.navigationController?.isNavigationBarHidden = true
        
        historyButton.layer.cornerRadius = 5
        
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
        makeHamon()
        
        count += 1
        countLabel.text = "\(count)"
        
        savePornHistory()


        
    }
    
    fileprivate func savePornHistory() {
        
        let realm = try! Realm()
        
        let history = pornHistory()
        history.count = count
        history.number = number
        history.pressDateTime = Date()
        
        let namesTable = realm.objects(historyName.self)
        let structName = historyName()
        
        if let lastNames = namesTable.last {
            if lastNames.number != number {
                
                structName.number = number
                structName.historyName = "ポーン履歴 \(number + 1)"
                
                try! realm.write {
                    realm.add(history)
                    realm.add(structName)
                }
                
            } else {
                try! realm.write {
                    realm.add(history)
                }
            }
        } else {
            
            structName.number = number
            structName.historyName = "ポーン履歴 \(number + 1)"
            
            try! realm.write {
                realm.add(history)
                realm.add(structName)
            }
            
        }
    
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
        
    }

    
    fileprivate func reset() {
        
        if count == 0 {
            return
        }
        
        count = 0
        countLabel.text = "\(count)"
        number += 1
        
        savePornHistory()
        
        presentInterstitial()
        
    }
    
    @IBAction func pressResetButton(_ sender: Any) {
        
        reset()
        
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
    
    
    @IBAction func returnViewController(_ segue: UIStoryboardSegue) {
        //print("\(#function) is called!")
    }
    
    
    fileprivate func viewHamon(size: CGFloat) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGRect(x: 100, y: 100, width: size, height: size).size, false, 0.0)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(self.view.frame)
        
        let x = CGFloat(size/2)
        let y = CGFloat(size/2)
        let r = CGFloat((size/2)-10)
        
        
        let path : CGMutablePath = CGMutablePath()
        
        path.addArc(center: CGPoint(x: x, y: y) , radius: r, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: false)
        
        context.addPath(path)
        context.setStrokeColor(UIColor.white.cgColor)
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        context.restoreGState()
        
        return image!
    }
    
    fileprivate func makeHamon() {
        
        //let location = view.center
        let location = CGPoint(x: view.center.x, y: countLabel.center.y)

        
        for i in 0 ..< 3 {
            
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: location.x, y: location.y, width: 100, height: 100)
            layer.position = CGPoint(x: location.x, y: location.y)
            let image = viewHamon(size: 100)
            layer.contents = image.cgImage
            
            self.view.layer.addSublayer(layer)
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(5.0)
            CATransaction.setCompletionBlock({
                layer.removeFromSuperlayer()
            })
            
            
            let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
            
            animation.duration = 3
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            animation.toValue = NSNumber(value: 2.0)
            
            
            let animation2 : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
            animation2.delegate = self
            animation2.duration = 3
            animation2.isRemovedOnCompletion = false
            animation2.fillMode = kCAFillModeForwards
            animation2.fromValue = NSNumber(value: 1.0)
            animation2.toValue = NSNumber(value: 0.0)
            
            let group : CAAnimationGroup = CAAnimationGroup()
            group.beginTime = CACurrentMediaTime() + Double(i)*0.35
            group.animations = [animation, animation2]
            group.isRemovedOnCompletion = false
            group.fillMode = kCAFillModeBackwards
            
            layer.add(group, forKey: "scale")
            layer.opacity = 0.0
            CATransaction.commit()
        }
        
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        reset()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
    }
    
    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?) {
        
    }
    
    @IBAction func pressHistoryButton(_ sender: Any) {
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        let realm = try! Realm()
        let names = realm.objects(historyName.self).sorted(byProperty: "number")
        
        
        if let lastName = names.last {
            number = lastName.number
        } else {
            number = 0
        }
        
        print("number = \(number)")
        
        
        
        let histories = realm.objects(pornHistory.self).filter("number = \(number)").sorted(byProperty: "count")
        print("\(histories)")
        
        if let lastHistory = histories.last {
            count = lastHistory.count
            number = lastHistory.number
        } else {
            savePornHistory()
        }
        
        countLabel.text = "\(count)"
        
    }
    
    @IBAction func pressResetButton_(_ sender: Any) {
        
        reset()

        
    }

}

