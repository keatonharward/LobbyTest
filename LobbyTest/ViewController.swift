//
//  ViewController.swift
//  LobbyTest
//
//  Created by Keaton Harward on 9/14/17.
//  Copyright © 2017 Keaton Harward. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var dataSource: UITableViewDataSource?
    
    @IBOutlet weak var peerList: UITableView!
    
    override func viewDidLoad() {
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
                LocalPeerManager.shared.hostSession(username: "Name", game: "Game")
                peerList.delegate = self
            }
        default: break
        }
        peerList.reloadData()
    }
}

