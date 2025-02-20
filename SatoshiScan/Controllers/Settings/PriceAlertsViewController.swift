//
//  PriceAlertsViewController.swift
//  SatoshiScan
//
//  Created by Aman on 18/2/25.
//

import UIKit

class PriceAlertsViewController: UIViewController {
    
    private let tableView = UITableView()
    private var alerts: [PriceAlert] = []
    private var selectedSymbol: String = "BTC"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Price Alerts"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        loadAlerts()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewAlert)
        )
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadAlerts() {
        alerts = CoreDataManager.shared.fetchPriceAlerts()
        tableView.reloadData()
    }
    
    @objc private func addNewAlert() {
        let selectCurrencyVC = SelectCurrencyForAlertViewController()
        selectCurrencyVC.delegate = self
        navigationController?.pushViewController(selectCurrencyVC, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PriceAlertsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let alert = alerts[indexPath.row]
        cell.textLabel?.text = "\(alert.symbol ?? "Unknown") - Target: $\(String(format: "%.2f", alert.targetPrice))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            let alertToRemove = self.alerts[indexPath.row]
            CoreDataManager.shared.removePriceAlert(alert: alertToRemove)
            self.alerts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension PriceAlertsViewController: SelectCurrencyForAlertDelegate {
    func didSelectCurrencyForAlert(symbol: String) {
        let alertVC = UIAlertController(
            title: "Set Target Price",
            message: "Enter target price for \(symbol)",
            preferredStyle: .alert
        )
        
        alertVC.addTextField { field in
            field.placeholder = "Target Price (USD)"
            field.keyboardType = .decimalPad
        }
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertVC.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let priceText = alertVC.textFields?[0].text,
                  let price = Double(priceText) else { return }
            
            CoreDataManager.shared.addPriceAlert(symbol: symbol.uppercased(), targetPrice: price)
            self.loadAlerts()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        
        present(alertVC, animated: true)
    }
}
