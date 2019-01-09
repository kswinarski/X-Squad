//
//  CardViewController.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation
import UIKit

class CardViewController: UIViewController {
	
	let card: Card
	let cardView = CardView()
	let costView = CardCostView()
	let upgradeBar = UIStackView()
	
	private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: view)
	private var attach: UIAttachmentBehavior?
	
	init(card: Card) {
		self.card = card
		super.init(nibName: nil, bundle: nil)
		
		transitioningDelegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.navigationBar.barStyle = .black
		view.backgroundColor = .black
		
		view.addSubview(cardView)
		let cardWidth = view.frame.width - 20
		cardView.frame = CGRect(origin: .zero, size: CGSize(width: cardWidth, height: cardWidth * CardView.heightMultiplier(for: card)))
		cardView.center = CGPoint(x: view.center.x, y: view.center.y - 20)
		
		cardView.card = card
		cardView.snap.snapPoint = cardView.center
		animator.addBehavior(cardView.snap)
		animator.addBehavior(cardView.behaviour)
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCard(recognizer:)))
		panGesture.maximumNumberOfTouches = 1
		cardView.addGestureRecognizer(panGesture)
		cardView.isUserInteractionEnabled = true
		
		let cardLayoutGuide = UILayoutGuide()
		view.addLayoutGuide(cardLayoutGuide)
		cardLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: cardView.frame.minY).isActive = true
		cardLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.height - cardView.frame.maxY)).isActive = true
		cardLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
		cardLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
		
		view.insertSubview(costView, belowSubview: cardView)
		costView.translatesAutoresizingMaskIntoConstraints = false
		costView.card = card
		
		costView.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: 15).isActive = true
		costView.rightAnchor.constraint(equalTo: cardLayoutGuide.rightAnchor, constant: -10).isActive = true
		
		upgradeBar.translatesAutoresizingMaskIntoConstraints = false
		upgradeBar.axis = .horizontal
		view.insertSubview(upgradeBar, belowSubview: cardView)
		
		upgradeBar.topAnchor.constraint(equalTo: cardLayoutGuide.bottomAnchor, constant: 15).isActive = true
		upgradeBar.leftAnchor.constraint(equalTo: cardLayoutGuide.leftAnchor, constant: 10).isActive = true
		
		for upgrade in card.availableUpgrades {
			let upgradeButton = UpgradeButton()
			upgradeButton.isUserInteractionEnabled = false
			upgradeButton.upgrade = upgrade
			
			upgradeBar.addArrangedSubview(upgradeButton)
		}
	}
	
	@objc func panCard(recognizer: UIPanGestureRecognizer) {
		let distance = hypot(cardView.center.x - view.center.x, cardView.center.y - view.center.y)
		
		switch recognizer.state {
		case .began:
			animator.removeBehavior(cardView.snap)
			
			let locationInCard = recognizer.location(in: cardView)
			let offsetFromCenterInCard = UIOffset(
				horizontal: locationInCard.x - cardView.bounds.midX,
				vertical: locationInCard.y - cardView.bounds.midY)
			
			let locationInView = recognizer.location(in: view)
			
			attach = UIAttachmentBehavior(
				item: cardView,
				offsetFromCenter: offsetFromCenterInCard,
				attachedToAnchor: locationInView)
			
			animator.addBehavior(attach!)
			
		case .changed:
			let anchor = recognizer.location(in: view)
			attach?.anchorPoint = anchor
			
			let backgroundPercent = 1 - distance/500
			view.backgroundColor = UIColor.black.withAlphaComponent(backgroundPercent)
			
			let HUDPercent = 1 - distance/200
			costView.alpha = HUDPercent
			upgradeBar.alpha = HUDPercent
			
		case .cancelled, .ended, .failed:
			if let attach = attach {
				animator.removeBehavior(attach)
			}
			attach = nil
			
			let velocity = recognizer.velocity(in: view)
			let velocityLength = hypot(velocity.x, velocity.y)
			
			if distance > 200 || velocityLength > 1000 {
				dismiss(animated: true, completion: nil)
			} else {
				animator.addBehavior(cardView.snap)
				
				UIView.animate(withDuration: 0.2) {
					self.view.backgroundColor = .black
					self.costView.alpha = 1.0
					self.upgradeBar.alpha = 1.0
				}
			}
		case.possible:
			break
		}
	}
	
}

extension CardViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsPresentAnimationController(animator: animator)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return CardsDismissAnimationController(animator: animator)
	}
	
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return nil
	}
}
