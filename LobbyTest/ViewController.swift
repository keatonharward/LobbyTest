//
//  ViewController.swift
//  LobbyTest
//
//  Created by Keaton Harward on 9/14/17.
//  Copyright © 2017 Keaton Harward. All rights reserved.
//

import UIKit
import PeerKit

class ViewController: UIViewController {
    var dataSource: UITableViewDataSource?
    var username: String?
    var game = "Poker"
    
    @IBOutlet weak var peerList: UITableView!
    @IBOutlet weak var hostLabel: UILabel!
    
    override func viewDidLoad() {
        PeerKit.myName = UIDevice.current.name
        username = PeerKit.myName
        peerList.dataSource = dataSource
        peerList.delegate = self
        LocalPeerManager.shared.delegate = self
    }
    
    @IBAction func hostButtonTapped(_ sender: Any) {
        updatePeers(withDataSource: .host)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
       updatePeers(withDataSource: .search)
    }
    
    @IBAction func listButtonTapped(_ sender: Any) {
        updatePeers(withDataSource: .connected)
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: LocalPeerProtocol {
    func updatePeers(withDataSource dataSourceType: dataSourceType) {
        switch dataSourceType {
        case .connected :
            if (self.dataSource is ConnectedPeersDataSource) == false {
                dataSource = ConnectedPeersDataSource()
                peerList.dataSource = dataSource
                peerList.delegate = self
            }
        case .search :
            if (self.dataSource is SearchDataSource) == false {
                dataSource = SearchDataSource()
                peerList.dataSource = dataSource
                peerList.delegate = dataSource as? UITableViewDelegate
                LocalPeerManager.shared.searchForSession()
            }
        case .host :
            if !(self.dataSource is HostDataSource) {
                dataSource = HostDataSource()
                peerList.dataSource = dataSource
                LocalPeerManager.shared.hostSession(username: username!, game: game)
                peerList.delegate = self
            }
        default: break
        }
        if LocalPeerManager.shared.userIsHost {
            hostLabel.text = "ME!"
        } else {hostLabel.text = LocalPeerManager.shared.sessionHost?.displayName}
        peerList.reloadData()
    }
}

