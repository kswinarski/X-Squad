//
//  Member.swift
//  X-Squad
//
//  Created by Avario on 22/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import Foundation

extension Squad {
	class Member: Codable {
		let uuid: UUID
		
		let shipXWS: XWSID
		let pilotXWS: XWSID
		var upgradesXWS: [XWSID]
		
		lazy var ship: Ship = DataStore.ship(for: shipXWS)!
		lazy var pilot: Pilot = DataStore.pilot(for: pilotXWS)!
		lazy var upgrades: [Upgrade] = upgradesXWS.map({  DataStore.upgrade(for: $0)! })//.sorted(by: upgradeSort)
		
		init(ship: Ship, pilot: Pilot, upgrades: [Upgrade] = []) {
			self.uuid = UUID()
			self.shipXWS = ship.xws
			self.pilotXWS = pilot.xws
			self.upgradesXWS = upgrades.map({ $0.xws })
		}
		
		var squad: Squad {
			return SquadStore.squads.first(where: { $0.members.contains(self) })!
		}
		
		var pointCost: Int {
			return upgrades.reduce(pilot.pointCost(), { $0 + $1.pointCost(for: self) })
		}
		
		lazy var upgradeSort: (Upgrade, Upgrade) -> Bool = { (lhs, rhs) -> Bool in
			let upgradeSlots = self.allSlots

			let lhsType = lhs.primarySide.type
			let rhsType = rhs.primarySide.type

			guard let lhsIndex = upgradeSlots.firstIndex(of: lhsType),
				let rhsIndex = upgradeSlots.firstIndex(of: rhsType) else {
					return false
			}

			if lhsType == rhsType {
				return lhs.name < rhs.name
			} else {
				return lhsIndex < rhsIndex
			}
		}
		
		func addUpgrade(_ upgrade: Upgrade) {
			upgradesXWS.append(upgrade.xws)
			upgrades.append(upgrade)
			
			removeInValidUpgrades()
			
			upgrades.sort(by: upgradeSort)
			
			SquadStore.save()
			NotificationCenter.default.post(name: .squadStoreDidAddUpgradeToMember, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
		}
		
		func remove(upgrade: Upgrade) {
			if let index = upgrades.firstIndex(of: upgrade),
				let indexXWS = upgradesXWS.firstIndex(of: upgrade.xws) {
				upgrades.remove(at: index)
				upgradesXWS.remove(at: indexXWS)
			}
			
			removeInValidUpgrades()
			
			SquadStore.save()
			NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromMember, object: self)
			NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
		}
		
		func removeInValidUpgrades(shouldNotify: Bool = false, notify: Bool = false) {
			var invalidUpgrade: Upgrade? = nil
			
			for upgrade in upgrades {
				guard validity(of: upgrade, replacing: upgrade) == .valid else {
					invalidUpgrade = upgrade
					break
				}
			}
			
			if let invalidUpgrade = invalidUpgrade,
				let index = upgrades.firstIndex(of: invalidUpgrade),
				let indexXWS = upgradesXWS.firstIndex(of: invalidUpgrade.xws){
				upgrades.remove(at: index)
				upgradesXWS.remove(at: indexXWS)
				removeInValidUpgrades(shouldNotify: shouldNotify, notify: true)
			}
			
			if shouldNotify, notify {
				NotificationCenter.default.post(name: .squadStoreDidRemoveUpgradeFromMember, object: self)
				NotificationCenter.default.post(name: .squadStoreDidUpdateSquad, object: squad)
			}
		}
		
		enum UpgradeValidity {
			case valid
			case alreadyEquipped
			case slotsNotAvailable
			case limitExceeded
			case restrictionsNotMet
		}
		
		func validity(of upgrade: Upgrade, replacing: Upgrade?) -> UpgradeValidity {
			// Ensure the any restrictions of the upgrade are met
			if let restrictionSets = upgrade.restrictions {
				checkingRestrictionSets: for restrictionSet in restrictionSets {
					for restriction in restrictionSet.restrictions {
						switch restriction {
						case .factions(let factions):
							if factions.contains(squad.faction) {
								continue checkingRestrictionSets
							}
							
						case .action(let action):
							if allActions.contains(where: {
								$0.type == action.type &&
									$0.difficulty == action.difficulty
							}) {
								continue checkingRestrictionSets
							}
							
						case .ships(let ships):
							if ships.contains(where: {
								$0 == pilot.ship!.xws
							}) {
								continue checkingRestrictionSets
							}
							
						case .sizes(let sizes):
							if sizes.contains(where: {
								$0 == pilot.ship!.size
							}) {
								continue checkingRestrictionSets
							}
							
						case .names(let names):
							for name in names {
								if squad.members.contains(where: {
									$0.pilot.name == name ||
										$0.upgrades.contains(where: { $0.name == name })
								}) {
									continue checkingRestrictionSets
								}
							}
							
						case .arcs(let arcs):
							for arc in arcs {
								if pilot.ship!.stats.map({ $0.arc }).compactMap({ $0 }).contains(arc) {
									continue checkingRestrictionSets
								}
							}
							
						case .forceSides(let forceSides):
							for forceSide in forceSides {
								if allForceSides.contains(forceSide) {
									continue checkingRestrictionSets
								}
							}
						}
					}
					
					return .restrictionsNotMet
				}
			}
			
			// Ensure the the pilot has the correct upgrade slots available for the upgrade
			var availablelots = upgrades.reduce(allSlots) { availablelots, upgrade in
				if upgrade == replacing {
					return availablelots
				}
				
				return upgrade.primarySide.slots.reduce(availablelots) {
					var availablelots = $0
					if let index = availablelots.index(of: $1) {
						availablelots.remove(at: index)
					}
					return availablelots
				}
			}
			
			for slot in upgrade.primarySide.slots {
				guard let index = availablelots.index(of: slot) else {
					return .slotsNotAvailable
				}
				availablelots.remove(at: index)
			}
			
			// Make sure the card limit is not exceeded
			switch squad.limitStatus(for: upgrade) {
			case .met:
				if upgrade == replacing {
					break
				} else {
					fallthrough
				}
			case .exceeded:
				return .limitExceeded
			case .available:
				break
			}
			
			// A pilot can never have two of the same upgrade
			guard upgrade == replacing || upgrades.contains(upgrade) == false else {
				return .alreadyEquipped
			}
			
			return .valid
		}
	}
}

extension Squad.Member: Hashable {
	static func == (lhs: Squad.Member, rhs: Squad.Member) -> Bool {
		return lhs.uuid == rhs.uuid
	}
	
	public func hash(into hasher: inout Hasher) {
		uuid.hash(into: &hasher)
	}
}

extension Squad.Member {
	var allSlots: [Upgrade.UpgradeType] {
		var upgradeSlots = upgrades.reduce(pilot.slots ?? [], {
			$1.sides.reduce($0, {
				guard let grants = $1.grants else {
					return $0
				}
				
				return grants.reduce($0, {
					switch $1.type {
					case .slot(let slot, let amount):
						switch amount {
						case 1:
							return $0 + [slot]
						case -1:
							var slots = $0
							if let index = slots.firstIndex(of: slot) {
								slots.remove(at: index)
							}
							return slots
						default:
							return $0
						}
					default:
						return $0
					}
				})
			})
		})
		
		if pilot.shipAbility?.name == "Weapon Hardpoint" {
			let hardpointUpgrades: [Upgrade.UpgradeType] = [.cannon, .torpedo, .missile]
			if let equippedHardpointUpgrade = upgrades.first(where: { $0.sides.contains(where: { hardpointUpgrades.contains($0.type) })}) {
				upgradeSlots.append(equippedHardpointUpgrade.primarySide.type)
			} else {
				upgradeSlots.append(contentsOf: hardpointUpgrades)
			}
		}
		
		return upgradeSlots
	}
	
	var allActions: [Action] {
		return upgrades.reduce(ship.actions, {
			$1.sides.reduce($0, {
				guard let grants = $1.grants else {
					return $0
				}
				
				return grants.reduce($0, {
					switch $1.type {
					case .action(let action):
						return $0 + [action]
					default:
						return $0
					}
				})
			})
		})
	}
	
	var allForceSides: [Force.Side] {
		return upgrades.reduce([pilot.force?.side].compactMap({ $0 }).flatMap({ $0 }), {
			$1.sides.reduce($0, {
				guard let grants = $1.grants else {
					return $0
				}
				
				return grants.reduce($0, {
					switch $1.type {
					case .force(let force):
						guard let side = force.side else {
							fallthrough
						}
						return $0 + side
					default:
						return $0
					}
				})
			})
		})
	}
	
}
