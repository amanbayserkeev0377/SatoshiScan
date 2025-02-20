//
//  SelectCurrencyForAlertViewController.swift
//  SatoshiScan
//
//  Created by Aman on 19/2/25.
//

import UIKit

protocol SelectCurrencyForAlertDelegate: AnyObject {
    func didSelectCurrencyForAlert(symbol: String)
}

class SelectCurrencyForAlertViewController: UIViewController {
    
    private let tableView = UITableView()
    private var allCurrencies: [CryptoCurrency] = []
    weak var delegate: SelectCurrencyForAlertDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Currency"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        loadCurrencies()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CryptoSelectionCell.self, forCellReuseIdentifier: CryptoSelectionCell.identifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadCurrencies() {
        guard let tabBarController = self.tabBarController,
              let viewControllers = tabBarController.viewControllers,
              let marketVC = (viewControllers.compactMap { ($0 as? UINavigationController)?.viewControllers.first as? MarketViewController }).first else {
            print("MarketViewController not found, using default list")
            allCurrencies = [
                CryptoCurrency(symbol: "BTC", name: "Bitcoin", imageURL: nil),
                CryptoCurrency(symbol: "ETH", name: "Ethereum", imageURL: nil),
                CryptoCurrency(symbol: "XRP", name: "XRP", imageURL: nil)
            ]
            tableView.reloadData()
            return
        }

        allCurrencies = marketVC.viewModel.coins.map {
            CryptoCurrency(symbol: $0.symbol, name: $0.name, imageURL: $0.image)
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SelectCurrencyForAlertViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoSelectionCell.identifier, for: indexPath) as? CryptoSelectionCell else {
            return UITableViewCell()
        }
        let currency = allCurrencies[indexPath.row]
        cell.configure(with: currency)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCurrency = allCurrencies[indexPath.row].symbol
        delegate?.didSelectCurrencyForAlert(symbol: selectedCurrency)
        navigationController?.popViewController(animated: true)
    }
}
