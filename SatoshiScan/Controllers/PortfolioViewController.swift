//
//  PortfolioViewController.swift
//  SatoshiScan
//
//  Created by Aman on 14/2/25.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    private let tableView = UITableView()
    private var portfolioCoins: [PortfolioCoin] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "My Portfolio"
        
        setupTableView()
        fetchPortfolio()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func fetchPortfolio() {
        portfolioCoins = CoreDataManager.shared.fetchPortfolio()
        tableView.reloadData()
    }
}

extension PortfolioViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portfolioCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let coin = portfolioCoins[indexPath.row]
        cell.textLabel?.text = "\(coin.name ?? "Unknow") - $\(coin.currentPrice)"
        return cell
    }
}
