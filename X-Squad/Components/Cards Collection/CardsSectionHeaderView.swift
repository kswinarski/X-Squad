//
//  CardsSectionHeader.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This is the header used for sections within the card collection view.

import Foundation
import UIKit

class CardsSectionHeaderView: UICollectionReusableView {
	
	static let reuseIdentifier = "CardsSectionHeaderView"
	
	let iconLabel = UILabel()
	let nameLabel = UILabel()
	
	let closeButton = SmallButton()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		addSubview(iconLabel)
		iconLabel.textAlignment = .center
		iconLabel.translatesAutoresizingMaskIntoConstraints = false
		iconLabel.textColor = UIColor.white.withAlphaComponent(0.5)//UIColor(named: "XRed")
		iconLabel.font = UIFont.xWingIcon(32)
		
		iconLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		iconLabel.widthAnchor.constraint(equalToConstant: 66).isActive = true
		iconLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
		
		addSubview(nameLabel)
		nameLabel.textColor = .white
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		
		nameLabel.leftAnchor.constraint(equalTo: iconLabel.rightAnchor).isActive = true
		nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		nameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
			
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.setTitle("Close", for: .normal)
		
		addSubview(closeButton)
		closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
		closeButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
