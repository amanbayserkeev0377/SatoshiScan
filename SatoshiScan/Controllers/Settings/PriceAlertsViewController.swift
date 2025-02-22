//
//  PriceAlertsViewController.swift
//  SatoshiScan
//
//  Created by Aman on 18/2/25.
//

import UIKit
import CoreData

class PriceAlertsViewController: UIViewController {
    
    private let tableView = UITableView()
    private var alerts: [PriceAlert] = []

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
        tableView.register(PriceAlertCell.self, forCellReuseIdentifier: PriceAlertCell.identifier)
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PriceAlertCell.identifier, for: indexPath) as? PriceAlertCell else {
            return UITableViewCell()
        }
        let alert = alerts[indexPath.row]
        cell.configure(with: alert)
        
        cell.switchAction = { [weak self] isEnabled in
            self?.updateAlertStatus(index: indexPath.row, isEnabled: isEnabled)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showEditAlert(for: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completionHandler in
            self?.deleteAlert(at: indexPath.row)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Handling Price Alerts
extension PriceAlertsViewController {
    
    private func updateAlertStatus(index: Int, isEnabled: Bool) {
        alerts[index].isEnabled = isEnabled
        CoreDataManager.shared.saveContext()
    }
    
    private func deleteAlert(at index: Int) {
        CoreDataManager.shared.deletePriceAlert(alerts[index])
        alerts.remove(at: index)
        tableView.reloadData()
    }

    private func showEditAlert(for index: Int) {
        let alert = UIAlertController(
            title: "Edit Price Alert",
            message: "Enter new target price for \(alerts[index].symbol ?? "Unknown")",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.keyboardType = UIKeyboardType.decimalPad
            textField.placeholder = "Enter new price"
            textField.text = "\(self.alerts[index].targetPrice)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let newPrice = Double(text) else { return }
            
            self.updateTargetPrice(for: index, newPrice: newPrice)
        }))
        
        present(alert, animated: true)
    }
    
    private func updateTargetPrice(for index: Int, newPrice: Double) {
        alerts[index].targetPrice = newPrice
        CoreDataManager.shared.saveContext()
        tableView.reloadData()
    }
}

// MARK: - SelectCurrencyForAlertDelegate
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
            guard let priceText = alertVC.textFields?.first?.text,
                  let price = Double(priceText) else { return }
            
            let imageURL = self.getImageURLForSymbol(symbol) ?? ""
            
            CoreDataManager.shared.addPriceAlert(symbol: symbol.uppercased(), targetPrice: price, imageURL: imageURL)
            
            DispatchQueue.main.async {
                self.loadAlerts()
                self.tableView.reloadData()
            }
        }))
        
        present(alertVC, animated: true)
    }
    
    private func getImageURLForSymbol(_ symbol: String) -> String? {
        
        guard let tabBarController = self.tabBarController else { return nil }

        for viewController in tabBarController.viewControllers ?? [] {
            if let navVC = viewController as? UINavigationController,
               let marketVC = navVC.viewControllers.first(where: { $0 is MarketViewController }) as? MarketViewController {

                return marketVC.viewModel.coins.first(where: { $0.symbol.lowercased() == symbol.lowercased() })?.image
            }
        }

        return nil
    }
}
