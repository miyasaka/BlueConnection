//
//  MessageCell.swift
//  BuletoothP2P
//
//  Created by m_gunji on 2016/02/26.
//  Copyright © 2016年 m_gunji. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    static let NibName = "MessageCell"
    static let height: CGFloat = 120.0
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
