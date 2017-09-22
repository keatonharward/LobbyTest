//
//  searchDataSource.swift
//  LobbyTest
//
//  Created by Keaton Harward on 9/14/17.
//  Copyright © 2017 Keaton Harward. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import PeerKit

class SearchDataSource: NSObject {
    var currentPeerIDs: [MCPeerID?]  = []
    var sessionData: [[String:String]?]  = []
    var username: String?
    
    override init() {
        super.init()
        username = PeerKit.myName
        LocalPeerManager.shared.discoveryDelegate = self
    }
}

extension SearchDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentPeerIDs.count == 0 { return 1 }
        return currentPeerIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        
        if currentPeerIDs.count == 0 {
            cell.textLabel?.text = "Searching..."
            cell.detailTextLabel?.text = ""
            return cell
        }
        
        guard let sessionInfo = sessionData[indexPath.row] else { return UITableViewCell()}
        
        cell.textLabel?.text = sessionInfo["Name"]
        cell.detailTextLabel?.text = sessionInfo["Game"]
        return cell
    }
}

extension SearchDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let host = currentPeerIDs[indexPath.row] {
            LocalPeerManager.shared.sessionHost = host
            if let sessionInfo = sessionData[indexPath.row], let sessionID = sessionInfo["sessionID"] {
                
                    LocalPeerManager.shared.sessionID = sessionID
                    LocalPeerManager.shared.connectTo(host: host, withName: username!, browserPosition: indexPath.row)
                
            }
        }
    }
}

extension SearchDataSource: LocalPeerDiscoveryProtocol {
    func discoveredPeerIsNew(peer: MCPeerID, sessionInfo: [String : String]?) -> Bool {
        let contains = currentPeerIDs.contains(where: {$0?.displayName == peer.displayName})
        if !contains {
            currentPeerIDs.append(peer)
            sessionData.append(sessionInfo)
        }
        return !contains
    }
}


