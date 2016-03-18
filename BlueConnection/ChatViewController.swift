//
//  ChatViewController.swift
//  BuletoothP2P
//
//  Created by m_gunji on 2016/03/02.
//  Copyright © 2016年 m_gunji. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var chatVIew: UIView!
    @IBOutlet weak var toolBarView: UIView!
    
    let manager = ServiceManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        let viewController = self.childViewControllers[1] as! ToolBarViewController
        viewController.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        guard let _ = parent as? PeerListViewController else {
            return
        }
        manager.disconeectedSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = sizeKeyboard(notification)!
        let duration = durationKeyboardAnimation(notification)!
        
        UIView.animateWithDuration(duration, animations: {
            self.mainView.frame.origin.y -= keyboardSize.size.height
            self.mainView.setNeedsLayout()
            self.mainView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardSize = sizeKeyboard(notification)!
        let duration = durationKeyboardAnimation(notification)!
        
        UIView.animateWithDuration(duration, animations: {
            self.mainView.frame.origin.y += keyboardSize.size.height
            self.mainView.setNeedsLayout()
            self.mainView.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func sizeKeyboard(notification: NSNotification) -> CGRect? {
        guard let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else {
            return nil
        }
        return rect
    }
    
    private func durationKeyboardAnimation(notification: NSNotification) -> NSTimeInterval? {
        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else {
            return nil
        }
        return duration
    }
}

extension ChatViewController: ToolBarViewControllerDelegate {
    
    func showPreview(view: PreviewImageView) {
        view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - view.frame.size.height, self.view.frame.size.width, view.frame.size.height)
        self.view.addSubview(view)
    }
    
    func hidePreview(view: PreviewImageView) {
        view.removeFromSuperview()
    }
}
