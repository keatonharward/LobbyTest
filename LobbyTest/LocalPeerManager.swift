//
//  LocalPeerManager.swift
//  LobbyTest
//
//  Created by Keaton Harward on 9/14/17.
//  Copyright © 2017 Keaton Harward. All rights reserved.
//

import Foundation
import PeerKit
import MultipeerConnectivity

enum dataSourceType {
    case host, search, connected, current
}

protocol LocalPeerProtocol {
    func updatePeers(withDataSource dataSource:dataSourceType)
}

protocol LocalPeerDiscoveryProtocol {
    func discoveredPeerIsNew(peer: MCPeerID, sessionInfo: [String:String]?) -> Bool
}

class LocalPeerManager: NSObject {
    static let shared = LocalPeerManager()
    var delegate: LocalPeerProtocol?
    var discoveryDelegate: LocalPeerDiscoveryProtocol?
    var connectedPeers: [MCPeerID?] = []
    var discoveryBrowsers: [MCNearbyServiceBrowser] = []
    
    override init() {
        super.init()
        
        PeerKit.onDiscovery = { peerID, sessionInfo in
            guard let discoveryData = sessionInfo as? [String:AnyObject] else {
                if self.discoveryDelegate!.discoveredPeerIsNew(peer: peerID, sessionInfo: nil) {
                    self.delegate?.updatePeers(withDataSource: dataSourceType.current)
                }
                return
            }
            
            
            let info: [String:String] = ["Name":discoveryData["Name"] as! String, "Game":discoveryData["Game"] as! String]
            
            if self.discoveryDelegate!.discoveredPeerIsNew(peer: peerID, sessionInfo: info) {
                let browser = discoveryData["Browser"]  as! MCNearbyServiceBrowser
                self.discoveryBrowsers.append(browser)
                self.delegate?.updatePeers(withDataSource: dataSourceType.current)
            }
        }
        
        PeerKit.onConnect = { _ in
            self.updatePeers(withDataSource: dataSourceType.connected)
        }
        
        PeerKit.onDisconnect = { _ in
            self.updatePeers()
        }
        
        PeerKit.onEvent = { peerID, event, object in
            self.updatePeers()
            if(event == "NameRequest") {
                
            }
        }
        
        
        
    }
    
    
    func hostSession(username: String, game: String) {
        let gameInfo = ["Name":username, "Game":game]
        PeerKit.advertise(serviceType: "LobbyTest", discoveryInfo: gameInfo)
    }
    
    func searchForSession() {
        PeerKit.browse(serviceType: "LobbyTest")
        
    }
    
    func connectTo(host: MCPeerID, withName username: String, browserPosition: Int) {
        let username = Data.init(base64Encoded: "Username")
        
        PeerKit.joinLocalSession(withHost: host, fromBrowser: discoveryBrowsers[browserPosition], withData: username)
    }
    
    func updatePeers(withDataSource dataSource:dataSourceType = dataSourceType.current) {
        delegate?.updatePeers(withDataSource: dataSource)
    }
}
