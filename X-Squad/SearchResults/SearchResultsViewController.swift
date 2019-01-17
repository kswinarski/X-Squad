//
//  SearchResultsViewController.swift
//  X-Squad
//
//  Created by Avario on 03/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit

class SearchResultsViewController: CardsViewController {
	
	init() {
		super.init(numberOfColumns: 2)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	var searchResults: [Card] = [] {
		didSet {
			cardSections = [CardSection(header: .none, cards: searchResults)]
		}
	}
	
}

extension SearchResultsViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard searchController.searchBar.text?.isEmpty == false else {
			searchResults = []
			collectionView.reloadData()
			return
		}
		
		searchResults = CardStore.searchResults(for: searchController.searchBar.text!)
		collectionView.reloadData()
	}
}