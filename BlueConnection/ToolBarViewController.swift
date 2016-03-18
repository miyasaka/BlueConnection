//
//  ToolBarViewController.swift
//  BuletoothP2P
//
//  Created by m_gunji on 2016/03/02.
//  Copyright © 2016年 m_gunji. All rights reserved.
//

import UIKit

protocol ToolBarViewControllerDelegate {
    func showPreview(view: PreviewImageView)
    func hidePreview(view: PreviewImageView)
}

class ToolBarViewController: UIViewController {
    
    @IBOutlet weak var messageTextField: UITextField!
    
    let manager = ServiceManager.sharedInstance
    weak var preview: PreviewImageView!
    var imagePicker: UIImagePickerController!
    
    var delegate: ToolBarViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedPostButton(sender: AnyObject) {
        if let str = messageTextField.text {
            manager.sendMessage(str)
        } else {
            manager.sendMessage("")
        }
        messageTextField.text = ""
        messageTextField.resignFirstResponder()
    }
    
    @IBAction func tappedOpenLibrary(sender: AnyObject) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

}

extension ToolBarViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        preview = PreviewImageView.instance
        preview.delegate = self
        preview.loadImage(image)
        preview.frame.size.width = self.view.frame.size.width
        preview.setNeedsLayout()
        preview.layoutIfNeeded()
        self.dismissViewControllerAnimated(true, completion: nil)
        delegate.showPreview(preview)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ToolBarViewController: PreviewImageViewDelegate {
    
    func closePreviewImageView() {
        preview.removeFromSuperview()
    }
    
}

extension ToolBarViewController: UITextFieldDelegate {
}


extension ToolBarViewController: UINavigationControllerDelegate {
    
}

