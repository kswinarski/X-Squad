//
//  SquadsViewController.swift
//  X-Squad
//
//  Created by Avario on 08/02/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This is an abstract class that displays a list of the user's squads.

import Foundation
import UIKit

class SquadsViewController: UITableViewController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	// The empty message is shown when the user has no squads.
	let emptyMessage: String
	
	init(emptyMessage: String) {
		self.emptyMessage = emptyMessage
		super.init(style: .plain)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .black
		
		definesPresentationContext = true
		
		tableView.separatorColor = UIColor.white.withAlphaComponent(0.2)
		tableView.rowHeight = SquadCell.rowHeight
		tableView.tableFooterView = UIView()
		
		tableView.register(SquadCell.self, forCellReuseIdentifier: SquadCell.reuseIdentifier)
		
		updateEmptyView()
		
		NotificationCenter.default.addObserver(self, selector: #selector(squadAdded), name: .squadStoreDidAddSquad, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(squadDeleted), name: .squadStoreDidDeleteSquad, object: nil)
	}
	
	@objc func squadAdded(notification: Notification) {
		guard let squad = notification.object as? Squad,
			let squadIndex = SquadStore.shared.squads.firstIndex(of: squad) else {
				return
		}
		
		tableView.reloadData()
		
		let indexPath = IndexPath(row: squadIndex, section: 0)
		tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
		tableView.deselectRow(at: indexPath, animated: true)
		
		updateEmptyView()
	}
	
	@objc func squadDeleted(notification: Notification) {
		tableView.reloadData()
		updateEmptyView()
	}
	
	func updateEmptyView() {
		tableView.backgroundView = SquadStore.shared.squads.isEmpty ? SquadsEmptyView(message: emptyMessage) : nil
	}
	
	@objc func addSquad() {
		present(UINavigationController(rootViewController: NewSquadViewController()), animated: true, completion: nil)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return SquadStore.shared.squads.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let squadCell = tableView.dequeueReusableCell(withIdentifier: SquadCell.reuseIdentifier) as! SquadCell
		if SquadStore.shared.squads.count > indexPath.row {
			squadCell.squad = SquadStore.shared.squads[indexPath.row]
		}
		
		return squadCell
	}
	
}
