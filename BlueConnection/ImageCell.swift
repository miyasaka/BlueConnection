//
//  ImageCell.swift
//  BuletoothP2P
//
//  Created by m_gunji on 2016/03/03.
//  Copyright © 2016年 m_gunji. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {

    static let NibName = "ImageCell"
    static let height: CGFloat = 120.0
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
