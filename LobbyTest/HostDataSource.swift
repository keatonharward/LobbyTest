//
//  HostDataSource.swift
//  LobbyTest
//
//  Created by Keaton Harward on 9/14/17.
//  Copyright © 2017 Keaton Harward. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class HostDataSource: NSObject {
    var peers: [MCPeerID?]
    var sessionData: [[String:String]?]
    
    override init() {
        peers = []
        sessionData = []
        super.init()
        LocalPeerManager.shared.discoveryDelegate = self
    }
}

extension HostDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if peers.count == 0 { return 1 }
        return peers.count
    }
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if peers.count == 0 {
            cell.textLabel?.text = "Hosting game"
            cell.detailTextLabel?.text = ""
            return cell
        }
        guard let gameInfo = sessionData[indexPath.row], let name = gameInfo["Name"], let game = gameInfo["Game"] else { return UITableViewCell()}
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = game
        return cell
    }
}

extension HostDataSource: LocalPeerDiscoveryProtocol {
    func discoveredPeerIsNew(peer: MCPeerID, sessionInfo: [String : String]?) -> Bool {
        let contains = peers.contains { existingPeer in
            existingPeer == peer
        }
        if !contains {
            LocalPeerManager.shared.sessionPeers?.append(peer)
            peers.append(peer)
            sessionData.append(sessionInfo)
        }
        
        return !contains
    }
}
