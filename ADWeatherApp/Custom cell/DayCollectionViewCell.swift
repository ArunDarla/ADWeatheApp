//
//  DayCollectionViewCell.swift
//  ADWeatherApp
//
//  Created by VIPadm on 24/04/21.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var cellBV: UIView!

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var feelLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var rainChancesLbl: UILabel!
    
    @IBOutlet weak var cloudTypeImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
