//
//  SettingsViewController.swift
//  SatoshiScan
//
//  Created by Aman on 17/2/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private enum Setting: String, CaseIterable {
        case currency = "Currency"
        case theme = "Theme"
        case priceAlerts = "Price Alerts"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        setupTableView()
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
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let setting = Setting.allCases[indexPath.row]
        
        cell.textLabel?.text = setting.rawValue
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = Setting.allCases[indexPath.row]
        
        switch setting {
        case .currency:
            let currencyVC = CurrencySelectionViewController()
            navigationController?.pushViewController(currencyVC, animated: true)
        case .theme:
            let themeVC = ThemeSelectionViewController()
            navigationController?.pushViewController(themeVC, animated: true)
        case .priceAlerts:
            let alertsVC = PriceAlertsViewController()
            navigationController?.pushViewController(alertsVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
