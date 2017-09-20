//
//  Browser.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

let timeStarted = NSDate()

public protocol browserDelegate {
    func discovered(discoveredPeer: MCPeerID, withObjects: [String:AnyObject]?)
}

class Browser: NSObject, MCNearbyServiceBrowserDelegate {
    
    let mcSession: MCSession
    var delegate: browserDelegate?
    
    init(mcSession: MCSession, delegate: browserDelegate? = nil) {
        self.mcSession = mcSession
        super.init()
        self.delegate = delegate
    }
    
    var mcBrowser: MCNearbyServiceBrowser?
    
    func startBrowsing(serviceType: String) {
        mcBrowser = MCNearbyServiceBrowser(peer: mcSession.myPeerID, serviceType: serviceType)
        mcBrowser?.delegate = self
        mcBrowser?.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        mcBrowser?.delegate = nil
        mcBrowser?.stopBrowsingForPeers()
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let browserObject = browser
        var discoveryObjects: [String : AnyObject] = ["Browser":browserObject]
        if let discoveryInfo = info as [String : AnyObject]?{
            discoveryObjects.merge(discoveryInfo, uniquingKeysWith: { (current, _) -> AnyObject in current })
        }
        delegate?.discovered(discoveredPeer: peerID, withObjects: discoveryObjects)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // unused
    }
}


