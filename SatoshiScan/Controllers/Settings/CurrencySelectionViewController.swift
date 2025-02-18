//
//  CurrencySelectionViewController.swift
//  SatoshiScan
//
//  Created by Aman on 18/2/25.
//

import UIKit

class CurrencySelectionViewController: UIViewController {
    
    private let tableView = UITableView()
    private let currencies = ["USD", "EUR", "KZT", "RUB"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Currency"
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
extension CurrencySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currency = currencies[indexPath.row]
        
        cell.textLabel?.text = currency
        
        let selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
        cell.accessoryType = (currency == selectedCurrency) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurrency = currencies[indexPath.row]
        
        UserDefaults.standard.setValue(selectedCurrency, forKey: "selectedCurrency")
        tableView.reloadData()
        
        navigationController?.popViewController(animated: true)
        
        NotificationCenter.default.post(name: Notification.Name("CurrencyChanged"), object: nil)
    }
}
