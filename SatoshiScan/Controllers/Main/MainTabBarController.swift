//
//  MainTabBarController.swift
//  SatoshiScan
//
//  Created by Aman on 17/2/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let marketVC = UINavigationController(rootViewController: CryptoListViewController())
        let portfolioVC = UINavigationController(rootViewController: PortfolioViewController())
        let watchlistVC = UINavigationController(rootViewController: WatchlistViewController())
        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        
        marketVC.tabBarItem = UITabBarItem(title: "Market", image: UIImage(systemName: "chart.bar"), tag: 0)
        portfolioVC.tabBarItem = UITabBarItem(title: "Portfolio", image: UIImage(systemName: "briefcase"), tag: 1)
        watchlistVC.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(systemName: "star"), tag: 2)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 3)
        
        viewControllers = [marketVC, portfolioVC, watchlistVC, settingsVC]
    }
}
