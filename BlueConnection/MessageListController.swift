//
//  MessageListController.swift
//  BuletoothP2P
//
//  Created by 郡司雅 on 2016/02/26.
//  Copyright © 2016年 郡司雅. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MessageListController: UIViewController {

    let manager = ServiceManager.sharedInstance
    
    @IBOutlet var messageListView: UITableView!
    
    var peerID: MCPeerID?
    var chatViewPosition: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let messageCellNib = UINib(nibName: MessageCell.NibName, bundle:nil)
        messageListView.registerNib(messageCellNib, forCellReuseIdentifier: MessageCell.NibName)
        
        let imageCellNib = UINib(nibName: ImageCell.NibName, bundle:nil)
        messageListView.registerNib(imageCellNib, forCellReuseIdentifier: ImageCell.NibName)
        
        messageListView.dataSource = self
        messageListView.delegate = self
        messageListView.separatorColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        manager.chatDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        manager.messageList.removeFirst(50)
    }
    
}

// MARK: - UITableViewDataSource

extension MessageListController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.messageList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = manager.messageList[indexPath.row]
        
        if let text = message.text {
            let cell = tableView.dequeueReusableCellWithIdentifier(MessageCell.NibName, forIndexPath: indexPath) as! MessageCell
            cell.nameLabel.text = message.peerID.displayName
            cell.messageLabel.text = text
            cell.frame.size.width = self.messageListView.frame.size.width
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        } else if let image = message.image {
            let cell = tableView.dequeueReusableCellWithIdentifier(ImageCell.NibName, forIndexPath: indexPath) as! ImageCell
            cell.nameLabel.text = message.peerID.displayName
            cell.imageView?.image = image
            cell.frame.size.width = self.messageListView.frame.size.width
            cell.imageView?.setNeedsLayout()
            cell.imageView?.layoutIfNeeded()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        }
        return UITableViewCell.init()
    }
    
}

// MARK: - UITableViewDelegate

extension MessageListController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return MessageCell.height
        return 300
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
}

// MARK: - ServiceManagerDelegate

extension MessageListController: ChatDelegate {
    
    func getNewMessage() {
        dispatch_async(dispatch_get_main_queue(), {
            self.messageListView.reloadData()
        })
    }
    
    func disconnectedAllPeers() {
        super.navigationController?.popViewControllerAnimated(true)
    }
}

