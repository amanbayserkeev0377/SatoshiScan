//
//  PortfolioViewController.swift
//  SatoshiScan
//
//  Created by Aman on 14/2/25.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var portfolioCoins: [PortfolioCoin] = []
    private var filteredCoins: [PortfolioCoin] = []
    private var currentSortOption: SortOption = .nameAscending
    
    private var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    private let webSocketManager = WebSocketManager()
    
    private let totalValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search in portfolio"
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
        fetchPortfolio()
        setupSearchController()
        startWebSocketUpdates()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Portfolio"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sort",
            style: .plain,
            target: self,
            action: #selector(showSortOptions)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(clearPortfolio)
        )
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        
        view.addSubview(totalValueLabel)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PortfolioCell.self, forCellReuseIdentifier: PortfolioCell.identifier)
        
        NSLayoutConstraint.activate([
            totalValueLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            totalValueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: totalValueLabel.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func fetchPortfolio() {
        portfolioCoins = CoreDataManager.shared.fetchPortfolio()
        sortPortfolio()
        updateTotalValue()
        tableView.reloadData()
    }
    
    private func updateTotalValue() {
        let totalValue = portfolioCoins.reduce(0.0) { $0 + ($1.currentPrice * $1.amount) }
        totalValueLabel.text = "Total Portfolio Value: $\(String(format: "%.2f", totalValue))"
    }

    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    private func startWebSocketUpdates() {
        let symbols = portfolioCoins.map { "\($0.symbol?.lowercased() ?? "")usdt" }
        webSocketManager.delegate = self
        webSocketManager.connect(symbols: symbols)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshPortfolio), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshPortfolio() {
        fetchPortfolio()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func clearPortfolio() {
        let alert = UIAlertController(
            title: "Clear Portfolio",
            message: "Are you sure you want to remove all coins from your portfolio?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            CoreDataManager.shared.clearPortfolio()
            self.portfolioCoins.removeAll()
            self.updateTotalValue()
            self.tableView.reloadData()
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func showSortOptions() {
        let alert = UIAlertController(title: "Sort Portfolio", message: "Choose sorting option", preferredStyle: .actionSheet)
        
        let options: [(String, SortOption)] = [
            ("Name (A-Z)", .nameAscending),
            ("Name (Z-A)", .nameDescending),
            ("Price (Low to High)", .priceAscending),
            ("Price (High to Low)", .priceDescending),
            ("Amount (High to Low)", .amountDescending),
            ("Amount (Low to High)", .amountAscending)
        ]
        
        for (title, option) in options {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                self.currentSortOption = option
                self.sortPortfolio()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    private func sortPortfolio() {
        SortManager.sortCoins(&portfolioCoins, by: currentSortOption)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension PortfolioViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredCoins.count : portfolioCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PortfolioCell.identifier, for: indexPath) as? PortfolioCell else {
            return UITableViewCell()
        }
        let coin = isFiltering ? filteredCoins[indexPath.row] : portfolioCoins[indexPath.row]
        cell.configure(with: coin)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PortfolioViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let coinToDelete = portfolioCoins[indexPath.row]
            CoreDataManager.shared.removeFromPortfolio(coin: coinToDelete)
            
            self.portfolioCoins.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.updateTotalValue()
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - WebSocketManagerDelegate
extension PortfolioViewController: WebSocketManagerDelegate {
    func didReceivePriceUpdate(symbol: String, price: Double) {
        guard let index = portfolioCoins.firstIndex(where: { "\($0.symbol?.lowercased() ?? "")usdt" == symbol.lowercased() }) else { return }
        
        let oldPrice = portfolioCoins[index].currentPrice
        portfolioCoins[index].currentPrice = price
        CoreDataManager.shared.saveContext()
        
        DispatchQueue.main.async {
            self.updateTotalValue()
            
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PortfolioCell {
                cell.updatePrice(newPrice: price)
            }
        }
        
        checkPriceChange(symbol: symbol, oldPrice: oldPrice, newPrice: price)
    }
    
    private func checkPriceChange(symbol: String, oldPrice: Double, newPrice: Double) {
        let percentageChange = ( (newPrice - oldPrice) / oldPrice) * 100
        
        if abs(percentageChange) >= 10 {
            let changeType = newPrice > oldPrice ? "increased" : "decreased"
            let message = "\(symbol.uppercased()) has \(changeType) by \(String(format: "%.2f", percentageChange))%!"
            
            sendPriceAlert(title: "Crypto Alert", body: message)
        }
    }
    
    private func sendPriceAlert(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent: \(body)")
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension PortfolioViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        
        filteredCoins = portfolioCoins.filter { coin in
            (coin.rawName?.lowercased().contains(searchText) ?? false) ||
            (coin.symbol?.lowercased().contains(searchText) ?? false)
        }
        
        tableView.reloadData()
    }
}
