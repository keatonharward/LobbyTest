//
//  Advertiser.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol advertiserDelegate {
    func requestToJoin(fromUser user: MCPeerID)
}

class Advertiser: NSObject, MCNearbyServiceAdvertiserDelegate {
    
    let mcSession: MCSession
    var delegate: advertiserDelegate?
    
    init(mcSession: MCSession) {
        self.mcSession = mcSession
        super.init()
    }
    
    private var advertiser: MCNearbyServiceAdvertiser?
    
    func startAdvertising(serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser = MCNearbyServiceAdvertiser(peer: mcSession.myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        advertiser?.delegate = nil
        advertiser?.stopAdvertisingPeer()
    }
    
    
    //    @available(iOSApplicationExtension 7.0, *)
        public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
            let contains = (mcSession.connectedPeers.contains(peerID))
            invitationHandler(!contains, mcSession)
        }
}

