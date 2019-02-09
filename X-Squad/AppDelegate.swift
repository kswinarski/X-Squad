//
//  AppDelegate.swift
//  X-Squad
//
//  Created by Avario on 02/01/2019.
//  Copyright © 2019 Avario. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
//		for family in UIFont.familyNames.sorted() {
//			let names = UIFont.fontNames(forFamilyName: family)
//			print("Family: \(family) Font names: \(names)")
//		}
		
//		#warning("Clear chache")
//		let cache = ImageCache.default
//		cache.clearMemoryCache()
//		cache.clearDiskCache { print("Done") }
		
//		UIView.appearance()
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window!.tintColor = UIColor(named: "XRed")
		
		UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.init(white: 0.8, alpha: 1.0)]
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.init(white: 0.8, alpha: 1.0)]
		UIToolbar.appearance().isTranslucent = false
		
		let tabBarController = UITabBarController()
		tabBarController.tabBar.barStyle = .black
		tabBarController.tabBar.isTranslucent = false
		
		tabBarController.viewControllers = [
			GameTab(),
			SquadsViewController(),
			SearchTab(),
			UINavigationController(rootViewController: SettingsViewController())]

		tabBarController.selectedIndex = 1
		
		window?.rootViewController = tabBarController//UINavigationController(rootViewController: _HomeViewController())
		
		window?.makeKeyAndVisible()
		
		return true
	}
	
}

