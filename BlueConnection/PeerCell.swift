//
//  PeerCell.swift
//  BuletoothP2P
//
//  Created by m_gunji on 2016/02/29.
//  Copyright © 2016年 m_gunji. All rights reserved.
//

import UIKit

class PeerCell: UITableViewCell {

    static let NibName = "PeerCell"
    static let height: CGFloat = 100.0

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
