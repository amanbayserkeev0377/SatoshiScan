//
//  WatchlistViewController.swift
//  SatoshiScan
//
//  Created by Aman on 17/2/25.
//

import UIKit

class WatchlistViewController: UIViewController {
    private let tableView = UITableView()
    private var watchlistCoins: [WatchlistCoin] = []
    private let webSocketManager = WebSocketManager()
    private let refreshControl = UIRefreshControl()
    private var currentSortOption: SortOption = .nameAscending
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite coins yet"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupRefreshControl()
        fetchWatchlist()
        startWebSocketUpdates()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Watchlist"
        
        let sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(showSortOptions))
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CryptoCell.self, forCellReuseIdentifier: CryptoCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    private func fetchWatchlist() {
        let newWatchlist = CoreDataManager.shared.fetchWatchlist()
        
        if watchlistCoins.isEmpty {
            watchlistCoins = newWatchlist
            tableView.reloadData()
        } else {
            let oldSymbols = Set(watchlistCoins.compactMap { $0.symbol })
            let newSymbols = Set(newWatchlist.compactMap { $0.symbol })
            
            let addedSymbols = newSymbols.subtracting(oldSymbols)
            let removedSymbols = oldSymbols.subtracting(newSymbols)
            
            let addedIndexes = addedSymbols.compactMap { symbol in
                newWatchlist.firstIndex { $0.symbol == symbol }
            }.map { IndexPath(row: $0, section: 0) }
            
            let removedIndexes = removedSymbols.compactMap { symbol in
                watchlistCoins.firstIndex { $0.symbol == symbol }
            }.map { IndexPath(row: $0, section: 0) }
            
            watchlistCoins = newWatchlist
            
            tableView.performBatchUpdates({
                tableView.insertRows(at: addedIndexes, with: .fade)
                tableView.deleteRows(at: removedIndexes, with: .fade)
            }, completion: nil)
        }
        
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        if watchlistCoins.isEmpty {
            view.addSubview(emptyLabel)
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            tableView.isHidden = true
        } else {
            emptyLabel.isHidden = !watchlistCoins.isEmpty
            tableView.isHidden = false
        }
    }

    private func startWebSocketUpdates() {
        let symbols = watchlistCoins.compactMap { "\($0.symbol?.lowercased() ?? "")usdt" }
        webSocketManager.delegate = self
        webSocketManager.connect(symbols: symbols)
        }
    
    private func convertToCrypto(from watchlistCoin: WatchlistCoin) -> Crypto {
        return Crypto(
            id: watchlistCoin.id ?? "",
            name: watchlistCoin.name ?? "",
            symbol: watchlistCoin.symbol ?? "",
            current_price: watchlistCoin.currentPrice,
            image: watchlistCoin.imageURL ?? "",
            price_change_percentage_24h: watchlistCoin.priceChangePercentage24h
        )
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshWatchlist), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func sortCoins() {
        var cryptoCoins = watchlistCoins.map { convertToCrypto(from: $0) }
        SortManager.sortCoins(&cryptoCoins, by: currentSortOption)
        watchlistCoins = cryptoCoins.map { convertToWatchlistCoin(from: $0) }
        tableView.reloadData()
    }
    
    private func convertToWatchlistCoin(from crypto: Crypto) -> WatchlistCoin {
        let watchlistCoin = WatchlistCoin(context: CoreDataManager.shared.context)
        watchlistCoin.id = crypto.id
        watchlistCoin.name = crypto.name
        watchlistCoin.symbol = crypto.symbol
        watchlistCoin.currentPrice = crypto.current_price
        watchlistCoin.imageURL = crypto.image
        watchlistCoin.priceChangePercentage24h = crypto.price_change_percentage_24h
        return watchlistCoin
    }
    
    @objc private func showSortOptions() {
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        
        let options: [(String, SortOption)] = [
            ("Name (A-Z)", .nameAscending),
            ("Name (Z-A)", .nameDescending),
            ("Price (Low to High)", .priceAscending),
            ("Price (High to Low)", .priceDescending),
            ("Change (Low to High)", .changeAscending),
            ("Change (High to Low)", .changeDescending)
        ]
        
        options.forEach { title, option in
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                self.currentSortOption = option
                self.sortCoins()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func refreshWatchlist() {
        fetchWatchlist()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension WatchlistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoCell.identifier, for: indexPath) as? CryptoCell else {
            return UITableViewCell()
        }
        let coin = watchlistCoins[indexPath.row]
        cell.configure(with: convertToCrypto(from: coin))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let coin = watchlistCoins[indexPath.row]
        let detailVC = CryptoDetailViewController(coin: convertToCrypto(from: coin))
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let coinToRemove = watchlistCoins[indexPath.row]
            CoreDataManager.shared.removeFromWatchlist(coin: convertToCrypto(from: coinToRemove))
            
            watchlistCoins.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - WebSocketManagerDelegate
extension WatchlistViewController: WebSocketManagerDelegate {
    func didReceivePriceUpdate(symbol: String, price: Double) {
        guard let index = watchlistCoins.firstIndex(where: { "\($0.symbol?.lowercased() ?? "")usdt" == symbol.lowercased() }) else { return }
        guard self.tableView.window != nil else { return }
        
        let previousPrice = watchlistCoins[index].currentPrice
        guard previousPrice > 0 else { return }
        
        if watchlistCoins[index].previousDayPrice == 0 {
            watchlistCoins[index].previousDayPrice = previousPrice
        }
        
        let changePercentage = ((price - watchlistCoins[index].previousDayPrice) / watchlistCoins[index].previousDayPrice) * 100
        let roundedChange = round(changePercentage * 100) / 100
        
        watchlistCoins[index].priceChangePercentage24h = abs(roundedChange) < 0.01 ? 0.01 : roundedChange
        watchlistCoins[index].currentPrice = price
        
        CoreDataManager.shared.saveContext()
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: index, section: 0)
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? CryptoCell {
                cell.updatePrice(newPrice: price, changePercentage: self.watchlistCoins[index].priceChangePercentage24h)
            } else {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}
