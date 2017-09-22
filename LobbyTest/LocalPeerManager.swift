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
    var discoveryBrowsers: [MCNearbyServiceBrowser] = []
    
    var sessionPeers: [MCPeerID]? = []
    var sessionHost: MCPeerID?
    var userIsHost = false
    var sessionID = ""
    
    override init() {
        super.init()
        
        PeerKit.onDiscovery = { peerID, sessionInfo in
            self.sessionPeers = PeerKit.session?.connectedPeers
            guard let discoveryData = sessionInfo as? [String:AnyObject] else {
                if self.discoveryDelegate!.discoveredPeerIsNew(peer: peerID, sessionInfo: nil) {
                    self.delegate?.updatePeers(withDataSource: dataSourceType.current)
                }
                return
            }
            let browser = discoveryData["Browser"]  as! MCNearbyServiceBrowser
            
            if self.sessionID == "" {
                let info: [String:String] = ["Name":discoveryData["Name"] as! String, "Game":discoveryData["Game"] as! String, "sessionID":discoveryData["sessionID"] as! String]
                if self.discoveryDelegate!.discoveredPeerIsNew(peer: peerID, sessionInfo: info) {
                    self.discoveryBrowsers.append(browser)
                    self.delegate?.updatePeers(withDataSource: dataSourceType.current)
                }
            } else {
                let info = ["sessionID": self.sessionID]
                if self.discoveryDelegate!.discoveredPeerIsNew(peer: peerID, sessionInfo: info) {
                    self.discoveryBrowsers.append(browser)
                    self.connectTo(host: peerID, withName: PeerKit.myName, browserPosition: self.discoveryBrowsers.count - 1)
                }
            }
        }
        
        PeerKit.onConnect = { _ in
            if self.userIsHost {
                self.sessionPeers = (PeerKit.session?.connectedPeers)!
                PeerKit.sendEvent("update peers", object: self.sessionPeers as AnyObject, toPeers: self.sessionPeers)
            } else {
                
            }
            
            self.updatePeers()
        }
        
        PeerKit.onDisconnect = { _ in
            if self.userIsHost {
                self.sessionPeers = PeerKit.session?.connectedPeers
                PeerKit.sendEvent("update peers", object: self.sessionPeers as AnyObject, toPeers: self.sessionPeers)
            }
            
            self.updatePeers()
        }
        
        PeerKit.onEvent = { peerID, event, object in
            self.updatePeers()
            switch event {
            case "update peers":
                let peersFromHost = object as! [MCPeerID]
                self.sessionPeers = PeerKit.session!.connectedPeers
                if peersFromHost.count > self.sessionPeers!.count {
                    let newPeers = peersFromHost.filter {
                        let peer = $0
                        return !self.sessionPeers!.contains {peer == $0}
                    }
                    for peer in newPeers {
                        self.addNewPeer(withSessionID: self.sessionID)
                    }
                }
            case "Play":
                let received = object as! [MCPeerID]?
            default: break
            }
        }
    }
    
    func sendEvent() {
        let move = sessionPeers as AnyObject
        
        PeerKit.sendEvent("Play", object: move, toPeers: PeerKit.session?.connectedPeers)
    }
    
    
    func hostSession(username: String, game: String) {
        getSessionID()
        let gameInfo = ["Name":username, "Game":game, "sessionID":sessionID]
        PeerKit.advertise(serviceType: "LobbyTest", discoveryInfo: gameInfo)
        PeerKit.browse(serviceType: sessionID)
        userIsHost = true
    }
    
    func getSessionID(){
        var id = UUID().uuidString
        id.removeLast(id.count - 15)
        sessionID = id
    }
    
    func addNewPeer(withSessionID sessionID: String) {
        PeerKit.browse(serviceType: sessionID)
        let gameInfo = ["Name":PeerKit.myName,"sessionID":sessionID]
        PeerKit.advertise(serviceType: sessionID, discoveryInfo: gameInfo)
    }
    
    func searchForSession() {
        
        PeerKit.browse(serviceType: "LobbyTest")
        
    }
    
    func connectTo(host: MCPeerID, withName username: String, browserPosition: Int) {
        let username = Data.init(base64Encoded: "Username")
        let sessionBrowser = discoveryBrowsers[browserPosition]
        PeerKit.joinLocalSession(withHost: host, fromBrowser: sessionBrowser, withData: username)
    }
    
    func updatePeers(withDataSource dataSource:dataSourceType = dataSourceType.current) {
        delegate?.updatePeers(withDataSource: dataSource)
    }
}
