//
//  SettingsViewController.swift
//  ADWeatherApp
//
//  Created by VIPadm on 25/04/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var metricBtn: UIButton!
    @IBOutlet weak var imperialBtn: UIButton!
    
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
