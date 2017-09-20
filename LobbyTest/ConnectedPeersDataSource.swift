//
//  ConnectedPeersDataSource.swift
//  LobbyTest
//
//  Created by Keaton Harward on 9/14/17.
//  Copyright © 2017 Keaton Harward. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import PeerKit

class ConnectedPeersDataSource: NSObject {
    var peers: [MCPeerID?] = []
    
    override init() {
        super.init()
        updatePeerList()
    }
    
    func updatePeerList() {
        if let session = PeerKit.session {
            peers = session.connectedPeers
        }
    }
}

extension ConnectedPeersDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if peers.count == 0 { return 1 }
        return peers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if peers.count == 0 {
            cell.textLabel?.text = "No connections"
            cell.detailTextLabel?.text = ""
            return cell
        }
        let peer = peers[indexPath.row]
        cell.textLabel?.text = peer?.displayName
        cell.detailTextLabel?.text = ""
        
        return cell
    }
}
