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
        view.backgroundColor = .systemBackground
        title = "Watchlist"
        
        setupTableView()
        fetchWatchlist()
        startWebSocketUpdates()
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
        watchlistCoins = CoreDataManager.shared.fetchWatchlist()
        tableView.reloadData()
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
            emptyLabel.removeFromSuperview()
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
            image: watchlistCoin.imageURL ?? ""
        )
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
        
        watchlistCoins[index].currentPrice = price
        CoreDataManager.shared.saveContext()
        
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CryptoCell {
                cell.updatePrice(newPrice: price)
            }
        }
    }
}
