
//
//  PreviewImageView.swift
//  BuletoothP2P
//
//  Created by 郡司雅 on 2016/03/03.
//  Copyright © 2016年 郡司雅. All rights reserved.
//

import UIKit

protocol PreviewImageViewDelegate {
    func closePreviewImageView()
}

class PreviewImageView: UIView {
    
    static let height: CGFloat = 300.0
    
    let manager = ServiceManager.sharedInstance
    var delegate: PreviewImageViewDelegate!
    
    @IBOutlet weak var imageView: UIImageView!
    
    static var instance: PreviewImageView {
        get {
            let view = UINib(nibName: "PreviewImageView", bundle:nil).instantiateWithOwner(nil, options: nil)[0] as! PreviewImageView
            return view
        }
    }
    
    func loadImage(image: UIImage) {
        imageView.image = image
    }
    
    @IBAction func tappedPostImageButton(sender: AnyObject) {
        delegate.closePreviewImageView()
        guard let image = imageView.image else {
            return
        }
        manager.sendImage(image)
    }
    
    @IBAction func tappedCancelButton(sender: AnyObject) {
        delegate.closePreviewImageView()
    }
}
