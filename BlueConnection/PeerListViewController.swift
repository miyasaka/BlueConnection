//
//  PeerListViewController.swift
//  BuletoothP2P
//
//  Created by m_gunji on 2016/02/29.
//  Copyright © 2016年 m_gunji. All rights reserved.
//

import UIKit

class PeerListViewController: UIViewController {

    // MARK: - 定数
    
    let manager = ServiceManager.sharedInstance
    
    var hud: MBProgressHUD!
    
    // MARK: - @IBOutlet
    
    @IBOutlet var peerListView: UITableView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let peerCellNib = UINib(nibName: PeerCell.NibName, bundle:nil)
        peerListView.registerNib(peerCellNib, forCellReuseIdentifier: PeerCell.NibName)
        peerListView.dataSource = self
        peerListView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        manager.resetPeerList()
        manager.authenticationdelegate = self
        manager.startBrowse()
        peerListView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
//        manager.stopBrowse()
//        manager.stopAdvertise()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showProglessWithButton() {
        hud = MBProgressHUD.showHUDAddedTo(peerListView, animated: true)
        hud.labelText = "アドバタイズ中"
        hud.detailsLabelText = "タップでキャンセル"
        hud.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: "cancelAdevertise:"))
//        self.performSegueWithIdentifier("showChatView",sender: nil)
    }

    func showProgless() {
        hud = MBProgressHUD.showHUDAddedTo(peerListView, animated: true)
        hud.labelText = "通信中"
    }
    
    func cancelAdevertise(sender: AnyObject) {
        manager.stopAdvertise()
        manager.startBrowse()
        dispatch_async(dispatch_get_main_queue(), {
            self.hud.hide(true)
        })
    }
    
    // MARK: - @IBAction
    
    @IBAction func tappedStartAdvertiseButton(sender: AnyObject) {
        manager.stopBrowse()
        manager.startAdvertise()
        showProglessWithButton()
    }
}

// MARK: - UITableViewDataSource

extension PeerListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.peerList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PeerCell.NibName, forIndexPath: indexPath) as! PeerCell
        let peer = manager.peerList[indexPath.row]
        if let string: String = peer.id.displayName {
            cell.nameLabel.text = string
        }
//        cell.infoLabel.text = manager.peerList[indexPath.row].info!["discript"]
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension PeerListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return PeerCell.height
    }
    
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        return nil
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        manager.invitePeer(indexPath.row)
        showProgless()
    }
}


// MARK: - AuthenticationDelegate

extension PeerListViewController: AuthenticationDelegate {
    
    func findPeer() {
        dispatch_async(dispatch_get_main_queue(), {
            self.peerListView.reloadData()
        })
    }
    
    func connectError() {
        dispatch_async(dispatch_get_main_queue(), {
            self.hud.hide(true)
        })
    }
    
    func connectedPeer() {
        guard let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController else {
            return
        }
        guard self == navigationController.topViewController else {
            return
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.hud.hide(true)
            self.performSegueWithIdentifier("showChatView",sender: nil)
        })
    }
    
}