//
//  ServiceManager.swift
//  BuletoothP2P
//
//  Created by 郡司雅 on 2016/02/26.
//  Copyright © 2016年 郡司雅. All rights reserved.
//

import Foundation
import MultipeerConnectivity

@objc protocol AuthenticationDelegate {
    optional func findPeer()
    optional func connectError()
    optional func connectedPeer()
}

@objc protocol DisconnectDelegate {
    optional func disconnectedAllPeers()
}

@objc protocol ChatDelegate {
    optional func getNewMessage()
}

class ServiceManager: NSObject {
    
    struct Peer {
        let id: MCPeerID
        let info: [String : String]?
        var state: MCSessionState
        
        init(peerID: MCPeerID, peerInfo: [String : String]?) {
            self.id = peerID
            self.info = peerInfo
            self.state = .NotConnected
        }
    }
    
    struct Message {
        let peerID: MCPeerID
        let text: String?
        let image: UIImage?
        
        init(peerID: MCPeerID, text: String) {
            self.peerID = peerID
            self.text = text
            self.image = nil
        }
        
        init(peerID: MCPeerID, image: UIImage) {
            self.peerID = peerID
            self.text = nil
            self.image = image
        }
        
        var arrayPeerID: [MCPeerID] {
            get {
                return [self.peerID]
            }
        }
    }
    
    static let sharedInstance = ServiceManager()
    
    let myPeerID = MCPeerID.init(displayName: UIDevice.init().name)
    var session: MCSession
    var serviceBrowser: MCNearbyServiceBrowser
    var serviceAdvertiser: MCNearbyServiceAdvertiser
    
    var messageList = [Message]()
    var peerList = [Peer]()
    var connectPeerList = [Peer]()
    var authenticationdelegate: AuthenticationDelegate?
    var disconnectDelegate: DisconnectDelegate?
    var chatDelegate: ChatDelegate?
    var stateServise = true
    
    // MARK: - Life Cycle
    
    private override init () {
        
        session = MCSession(peer: myPeerID, securityIdentity:nil, encryptionPreference:MCEncryptionPreference.Required)
        serviceBrowser = MCNearbyServiceBrowser.init(peer: myPeerID, serviceType: "MyService")
        let info = ["discript" : "this is test"]
        serviceAdvertiser = MCNearbyServiceAdvertiser.init(peer: myPeerID, discoveryInfo: info, serviceType: "MyService")
        
        super.init()
        
        session.delegate = self
        serviceBrowser.delegate = self
        serviceAdvertiser.delegate = self
        
    }
    
    // MARK: - Internal Function
    
    internal func browsingForPeers() {
        if stateServise {
            stateServise = false
            serviceAdvertiser.stopAdvertisingPeer()
            serviceBrowser.startBrowsingForPeers()
        } else {
            stateServise = true
            serviceBrowser.stopBrowsingForPeers()
            serviceAdvertiser.startAdvertisingPeer()
        }
    }
    
    internal func sendMessage(text: String) {
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {
            print("送信失敗")
            return
        }
        
        var peerIDList = [MCPeerID]()
        for peer in connectPeerList {
            peerIDList.append(peer.id)
        }
        guard peerIDList.count > 0 else {
            print("送信失敗")
            return
        }
        
        do {
            try session.sendData(data, toPeers: peerIDList, withMode: MCSessionSendDataMode.Reliable)
            let message = Message.init(peerID: myPeerID, text: text)
            self.messageList.append(message)
            chatDelegate?.getNewMessage?()
        } catch {
            print("送信失敗")
        }
    }

    internal func sendImage(image: UIImage) {
        
        var peerIDList = [MCPeerID]()
        for peer in connectPeerList {
            peerIDList.append(peer.id)
        }
        
        guard peerIDList.count > 0 else {
            print("送信失敗")
            return
        }

        guard let data = UIImageJPEGRepresentation(image, 10) else {
            print("送信失敗")
            return
        }
        
        let jpegData = NSData.init(data: data)
        do {
            try session.sendData(jpegData, toPeers: peerIDList, withMode: MCSessionSendDataMode.Reliable)
            let message = Message.init(peerID: myPeerID, image: image)
            self.messageList.append(message)
            chatDelegate?.getNewMessage?()
        } catch {
            print("送信失敗")
        }
        
    }
    
    internal func startBrowse() {
        serviceBrowser.startBrowsingForPeers()
    }
    
    internal func stopBrowse() {
        serviceBrowser.stopBrowsingForPeers()
    }
    
    internal func startAdvertise() {
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    internal func stopAdvertise() {
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    internal func invitePeer(row: Int) {
        serviceBrowser.invitePeer(peerList[row].id, toSession: session, withContext: nil, timeout: 30)
    }
    
    internal func disconeectedSession() {
        session.disconnect()
        for var peer in connectPeerList {
            peer.state = .NotConnected
        }
    }
    
    internal func resetPeerList() {
        peerList = [Peer]()
    }
    
}

// MARK: - MCSessionDelegate

extension ServiceManager: MCSessionDelegate {
    
    @objc
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
        print("certificateHandler")
    }
    
    @objc
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("certificateHandler \(state.rawValue)")
        switch state {
        case .NotConnected:
            authenticationdelegate?.connectError?()
            connectPeerList = connectPeerList.filter({$0.id != peerID})
            if connectPeerList.count == 0 {
                disconnectDelegate?.disconnectedAllPeers?()
            }
        case .Connecting:
            break
        case .Connected:
            connectPeerList = connectPeerList.filter({$0.id != peerID})
            let peer = Peer.init(peerID: peerID, peerInfo: nil)
            connectPeerList.append(peer)
            authenticationdelegate?.connectedPeer?()
        }
    }
    
    @objc
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        var message: Message
        if let text = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
            message = Message.init(peerID: peerID, text: text)
        } else if let image = UIImage.init(data: data) {
            message = Message.init(peerID: peerID, image: image)
        } else {
            return
        }
        self.messageList.append(message)
        self.chatDelegate?.getNewMessage?()
    }
    
    @objc
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    @objc
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    @objc
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
}

// MARK: - MCNearbyServiceBrowserDelegate

extension ServiceManager: MCNearbyServiceBrowserDelegate {
    
    @objc
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        peerList = peerList.filter({$0.id != peerID})
        let peer = Peer.init(peerID: peerID, peerInfo: info)
        peerList.append(peer)
        authenticationdelegate?.findPeer?()
    }
    
    @objc
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peerList = peerList.filter({$0.id != peerID})
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension ServiceManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("adv error")
    }
    
    @objc
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        invitationHandler(true, session)
        print("invited")
        connectPeerList = connectPeerList.filter({$0.id != peerID})
        let peer = Peer.init(peerID: peerID, peerInfo: nil)
        connectPeerList.append(peer)
    }
}
