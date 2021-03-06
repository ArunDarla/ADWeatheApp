//
//  SettingsViewController.swift
//  ADWeatherApp
//
//  Created by VIPadm on 25/04/21.
//

import UIKit
import AVFoundation

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var metricBtn: UIButton!
    @IBOutlet weak var imperialBtn: UIButton!
    
    @IBOutlet weak var demoVideoBV: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let isMetricType = UserDefaults.standard.bool(forKey: "IsMetricTypeKey")
        
        if isMetricType {
            metricBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            imperialBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        }else{
            metricBtn.setImage(UIImage(systemName: "circle"), for: .normal)
            imperialBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        }
        
        UserDefaults.standard.setValue(true, forKey: "IsMetricTypeKey")
        UserDefaults.standard.synchronize()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        playDemoVIdeoVideo(fileName: "DemoVideo.mov")
    }
    private func playDemoVIdeoVideo(fileName:String) {
        let file = fileName.components(separatedBy: ".")

        guard let path = Bundle.main.path(forResource: file[0], ofType:file[1]) else {
            debugPrint( "\(file.joined(separator: ".")) Demo video file not found")
            return
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = demoVideoBV.bounds
        demoVideoBV.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @IBAction func HomeButtonAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func MetricTypeButtonAction(sender: UIButton){
        
        metricBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        imperialBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        UserDefaults.standard.setValue(true, forKey: "IsMetricTypeKey")
        UserDefaults.standard.synchronize()
    }
    @IBAction func ImperialTypeButtonAction(sender: UIButton){
        
        metricBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        imperialBtn.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        UserDefaults.standard.setValue(false, forKey: "IsMetricTypeKey")
        UserDefaults.standard.synchronize()
    }
    
    
    
}
