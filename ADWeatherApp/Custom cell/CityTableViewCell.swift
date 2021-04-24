
//
//  CityTableViewCell.swift
//  apMap
//
//  Created by VIPadm on 23/04/21.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var cellBV: UIView!
    
    @IBOutlet weak var favorateBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
