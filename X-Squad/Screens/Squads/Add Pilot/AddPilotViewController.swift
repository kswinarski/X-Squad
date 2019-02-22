//
//  AddPilotViewController.swift
//  X-Squad
//
//  Created by Avario on 11/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//
// This Screen allows user's to add a pilot to squad by presenting a collection of all pilot cards.

import Foundation
import UIKit

class AddPilotViewController: CardsViewController {
	
	let squad: Squad
	
	var pullToDismissController: PullToDismissController?
	
	init(squad: Squad) {
		self.squad = squad
		super.init(numberOfColumns: 4)
		
		pullToDismissController = PullToDismissController()
		pullToDismissController?.viewController = self
		
		transitioningDelegate = self
		modalPresentationStyle = .overCurrentContext
		
		// The ships are sorted by how many pilots they have, then by name.
		let ships = DataStore.ships.filter({ $0.faction == squad.faction }).sorted {
			if $0.pilots.count == $1.pilots.count {
				return $0.name < $1.name
			} else {
				return $0.pilots.count > $1.pilots.count
			}
		}
		
		// Pilots are sorted into sections by their ship.
		for ship in ships {
			// Within a ship section, pilots are sorted according to PS and cost.
			let sortedPilots = ship.pilots.sorted(by: Squad.rankPilots)
			
			cardSections.append(
				CardSection(
					header: .header(
						CardSection.HeaderInfo(
							title: "",//shipType.title,
							icon: ship.characterCode,
							iconFont: UIFont.xWingShip(48)
						)
					),
					cards: sortedPilots
				)
			)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}

	// The pull to dismiss methods must be forwarded because this view must be the delegate (because it's a collection view).
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewWillBeginDragging(scrollView)
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		pullToDismissController?.scrollViewDidScroll(scrollView)
	}
	
	override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		pullToDismissController?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
	}
	
	override func squadAction(for card: Card) -> SquadButton.Action? {
		return status(for: card) == .default ? .add("Add to Squad") : nil
	}
	
	override func cardDetailsCollectionViewController(_ cardDetailsCollectionViewController: CardDetailsCollectionViewController, didPressSquadButtonFor card: Card) {
		let pilot = card as! Pilot
		let member = squad.addMember(for: pilot)
		
		cardDetailsCollectionViewController.currentCell?.member = member
		
		// The squad view controller is set as the target and this screen is set to hidden so it looks like the presented card screen transitions directly to the squad screen.
		self.view.isHidden = true
		cardDetailsCollectionViewController.dismissTargetViewController = self.presentingViewController
		cardDetailsCollectionViewController.dismiss(animated: true) {
			self.dismiss(animated: false, completion: nil)
		}
	}
	
	override func status(for card: Card) -> CardCollectionViewCell.Status {
		// Show cards the have reached their limit in the squad as dimmed.
		switch squad.limitStatus(for: card) {
		case .available:
			return .default
		case .exceeded, .met:
			return .unavailable
		}
	}
	
	override func cardViewDidForcePress(_ cardView: CardView, touches: Set<UITouch>, with event: UIEvent?) {
		let pilot = cardView.card as! Pilot
		guard squad.limitStatus(for: pilot) == .available else {
			return
		}
		
		cardView.touchesCancelled(touches, with: event)
		
		let member = squad.addMember(for: pilot)
		cardView.member = member
		
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
		
		dismiss(animated: true, completion: nil)
	}
}

extension AddPilotViewController: UIViewControllerTransitioningDelegate {
	
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
