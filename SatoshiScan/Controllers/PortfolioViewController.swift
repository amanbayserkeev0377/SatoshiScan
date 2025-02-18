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
        view.backgroundColor = .systemBackground
        title = "Portfolio"
        
        setupUI()
        setupRefreshControl()
        fetchPortfolio()
        
        setupSearchController()
        startWebSocketUpdates()
        
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
    }
    
    private func setupUI() {
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
        updateTotalValue()
        tableView.reloadData()
    }
    
    private func updateTotalValue() {
        let totalValue = portfolioCoins.reduce(into: 0.0) { $0 += $1.currentPrice * $1.amount }
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
        let alert = UIAlertController(title: "Sort Portfolio", message: "Choose sotring option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "By Price (High -> Low)", style: .default, handler: { _ in
            self.sortPortfolio(by: .priceDescending)
        }))
        alert.addAction(UIAlertAction(title: "By Price (Low -> High)", style: .default, handler: { _ in
            self.sortPortfolio(by: .priceAscending)
        }))
        alert.addAction(UIAlertAction(title: "By Name (A-Z)", style: .default, handler: { _ in
            self.sortPortfolio(by: .nameAscending)
        }))
        alert.addAction(UIAlertAction(title: "By Name (Z-A)", style: .default, handler: { _ in
            self.sortPortfolio(by: .nameDescending)
        }))
        alert.addAction(UIAlertAction(title: "By Amount (High -> Low)", style: .default, handler: { _ in
            self.sortPortfolio(by: .amountDescending)
        }))
        alert.addAction(UIAlertAction(title: "By Amount (Low -> High)", style: .default, handler: { _ in
            self.sortPortfolio(by: .amountAscending)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private enum SortOption {
        case priceDescending, priceAscending
        case nameAscending, nameDescending
        case amountDescending, amountAscending
    }
    
    private func sortPortfolio(by option: SortOption) {
        switch option {
        case .priceDescending:
            portfolioCoins.sort { $0.currentPrice > $1.currentPrice }
        case .priceAscending:
            portfolioCoins.sort { $0.currentPrice < $1.currentPrice }
        case .nameAscending:
            portfolioCoins.sort { ($0.name ?? "") < ($1.name ?? "") }
        case .nameDescending:
            portfolioCoins.sort { ($0.name ?? "") > ($1.name ?? "") }
        case .amountDescending:
            portfolioCoins.sort { $0.amount > $1.amount }
        case .amountAscending:
            portfolioCoins.sort { $0.amount < $1.amount }
        }
        
        tableView.reloadData()
    }
    
}
// MARK: - Extensions (temporary name)
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

extension PortfolioViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
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

extension PortfolioViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        
        filteredCoins = portfolioCoins.filter { coin in
            (coin.name?.lowercased().contains(searchText) ?? false) ||
            (coin.symbol?.lowercased().contains(searchText) ?? false)
        }
        
        tableView.reloadData()
    }
}
