//
//  CryptoListViewController.swift
//  SatoshiScan
//
//  Created by Aman on 13/2/25.
//

import UIKit

class CryptoListViewController: UIViewController {
    private let tableView = UITableView()
    private let viewModel = CryptoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchCryptoData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Portfolio",
            style: .plain,
            target: self,
            action: #selector(openPortfolio)
        )
    }
    
    private func setupUI() {
        title = "SatoshiScan"
        view.backgroundColor = .systemBackground
        
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
                self?.tableView.reloadData()
            }
        }
    }
    
    private func updateVisibleCells() {
        guard let visibleRows = tableView.indexPathsForVisibleRows else { return }
        
        for indexPath in visibleRows {
            guard let cell = tableView.cellForRow(at: indexPath) as? CryptoCell else { continue }
            let coin = viewModel.coins[indexPath.row]
            cell.updatePrice(newPrice: coin.current_price)
        }
    }
            
    @objc private func openPortfolio() {
        let portfolioVC = PortfolioViewController()
        navigationController?.pushViewController(portfolioVC, animated: true)
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension CryptoListViewController: UITableViewDataSource {
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

extension CryptoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCoin = viewModel.coins[indexPath.row]
        let detailVC = CryptoDetailViewController(coin: selectedCoin)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
