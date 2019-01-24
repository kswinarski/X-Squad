//
//  SelectUpgradeViewController.swift
//  X-Squad
//
//  Created by Avario on 13/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class SelectUpgradeViewController: CardsViewController {
	
	let squad: Squad
	let member: Squad.Member
	let currentUpgrade: Upgrade?
	let upgradeType: Upgrade.UpgradeType
	
	var pullToDismissController: PullToDismissController?
	
	init(squad: Squad, member: Squad.Member, currentUpgrade: Upgrade?, upgradeType: Upgrade.UpgradeType) {
		self.squad = squad
		self.member = member
		self.currentUpgrade = currentUpgrade
		self.upgradeType = upgradeType
		
		super.init(numberOfColumns: 3)
		
		pullToDismissController = PullToDismissController(viewController: self)
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
		
		var upgrades: [Upgrade] = []
		var restrictedUpgrades: [Upgrade] = []
		
		for upgrade in DataStore.upgrades {
			guard upgrade.primarySide.slots.contains(upgradeType) else {
					continue
			}
			
			if validity(of: upgrade) == .restrictionsNotMet {
				restrictedUpgrades.append(upgrade)
			} else {
				upgrades.append(upgrade)
			}
		}
		
		let upgradeSort: (Upgrade, Upgrade) -> Bool = {
			if $0.pointCost(for: member) == $1.pointCost(for: member) {
				return $0.name < $1.name
			}
			return $0.pointCost(for: member) > $1.pointCost(for: member)
		}
		
		cardSections.append(
			CardSection(
				header: .header(
					CardSection.HeaderInfo(
						title: "",
						icon: upgradeType.characterCode,
						iconFont: UIFont.xWingIcon(32)
					)
				),
				cards: upgrades.sorted(by: upgradeSort)
			)
		)
		
		cardSections.append(
			CardSection(
				header: .header(
					CardSection.HeaderInfo(
						title: "",
						icon: "",
						iconFont: UIFont.xWingIcon(32)
					)
				),
				cards: restrictedUpgrades.sorted(by: upgradeSort)
			)
		)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewWillBeginDragging(scrollView)
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewDidScroll(scrollView)
	}
	
	override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		pullToDismissController?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as! CardCollectionViewCell

		let upgrade = cardSections[indexPath.section].cards[indexPath.row] as! Upgrade
		cardCell.card = upgrade
		cardCell.status = status(for: upgrade)
		cardCell.cardView.delegate = self
		cardCell.cardView.member = member

		return cardCell
	}
	
	override func cardViewController(for card: Card) -> CardViewController {
		return CardViewController(card: card, member: member)
	}
	
	open override func squadActionForCardViewController(_ cardViewController: CardViewController) -> SquadButton.Action? {
		if cardViewController.card as? Upgrade == currentUpgrade {
			return .remove
		}
		
		if validity(of: cardViewController.card as! Upgrade) == .valid {
			return .add
		}
		
		return nil
	}
	
	open override func cardViewControllerDidPressSquadButton(_ cardViewController: CardViewController) {
		if let currentUpgrade = currentUpgrade {
			member.remove(upgrade: currentUpgrade)
		}
		
		if cardViewController.card as? Upgrade != currentUpgrade {
			member.addUpgrade(cardViewController.card as! Upgrade)
			cardViewController.cardView.member = member
		}
		
		let window = UIApplication.shared.keyWindow!
		let snapshot = cardViewController.view.snapshotView(afterScreenUpdates: false)!
		window.addSubview(snapshot)
		
		let baseViewController = self.presentingViewController!
		
		baseViewController.dismiss(animated: false) {
			baseViewController.present(cardViewController, animated: false) {
				snapshot.removeFromSuperview()
				baseViewController.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	override func status(for card: Card) -> CardCollectionViewCell.Status {
		guard let upgrade = card as? Upgrade else {
			fatalError()
		}
		
		guard validity(of: upgrade) == .valid else {
			return .unavailable
		}

		if let currentUpgrade = currentUpgrade,
			upgrade == currentUpgrade {
			return .selected
		}

		return .default
	}
	
	override func cardViewDidForcePress(_ cardView: CardView, touches: Set<UITouch>, with event: UIEvent?) {
		guard let upgrade = cardView.card as? Upgrade, validity(of: upgrade) == .valid else {
			return
		}
		
		cardView.touchesCancelled(touches, with: event)
		
		if upgrade != currentUpgrade {
			if let currentUpgrade = currentUpgrade {
				member.remove(upgrade: currentUpgrade)
			}
			
			member.addUpgrade(upgrade)
			cardView.member = member
		}
		
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		
		dismiss(animated: true, completion: nil)
	}
	
	func validity(of upgrade: Upgrade) -> Squad.Member.UpgradeValidity {
		return member.validity(of: upgrade, replacing: currentUpgrade)
	}
	
}

extension SelectUpgradeViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController()
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController()
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}