//
//  MarketViewController.swift
//  SatoshiScan
//
//  Created by Aman on 13/2/25.
//

import UIKit

class MarketViewController: UIViewController {
    
    private let tableView = UITableView()
    public let viewModel = CryptoViewModel()
    private let refreshControl = UIRefreshControl()
    private var currentSortOption: SortOption = .nameAscending
    
    var cryptocurrencies: [CryptoCurrency] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupRefreshControl()
        viewModel.fetchCryptoData()
        
    }
    
    private func setupUI() {
        title = "Market"
        view.backgroundColor = .systemBackground
        
        let sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(showSortOptions))
        navigationItem.rightBarButtonItem = sortButton
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.allowsSelection = true
        tableView.register(CryptoCell.self, forCellReuseIdentifier: CryptoCell.identifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.cryptocurrencies = self?.viewModel.coins.map { CryptoCurrency(symbol: $0.symbol, name: $0.name, imageURL: $0.image) } ?? []
                self?.tableView.reloadData()
            }
        }
    }
    
    private func updateVisibleCells() {
        guard let visibleRows = tableView.indexPathsForVisibleRows else { return }
        
        for indexPath in visibleRows {
            guard let cell = tableView.cellForRow(at: indexPath) as? CryptoCell else { continue }
            let coin = viewModel.coins[indexPath.row]
            
            cell.updatePrice(newPrice: coin.current_price, changePercentage: coin.price_change_percentage_24h)
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func sortCoins() {
        SortManager.sortCoins(&viewModel.coins, by: currentSortOption)
        tableView.reloadData()
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
    
    @objc private func refreshData() {
        viewModel.fetchCryptoData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
            
    @objc private func openPortfolio() {
        let portfolioVC = PortfolioViewController()
        navigationController?.pushViewController(portfolioVC, animated: true)
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension MarketViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoCell.identifier, for: indexPath) as? CryptoCell else {
            return UITableViewCell()
        }
        let coin = viewModel.coins[indexPath.row]
        cell.configure(with: coin)
        return cell
    }
}

extension MarketViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCoin = viewModel.coins[indexPath.row]
        let detailVC = CryptoDetailViewController(coin: selectedCoin)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
