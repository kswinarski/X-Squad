//
//  SettingCell.swift
//  X-Squad
//
//  Created by Avario on 08/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This is the simple cell used on the settings screen.

import Foundation
import UIKit

class SettingCell: UITableViewCell {
	
	static let reuseIdentifier = "SettingCell"
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
		
		contentView.backgroundColor = .clear
		backgroundColor = UIColor(white: 0.05, alpha: 1.0)
		textLabel?.textColor = UIColor.white.withAlphaComponent(0.8)
		
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.init(white: 0.20, alpha: 1.0)
		selectedBackgroundView = backgroundView
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
}
