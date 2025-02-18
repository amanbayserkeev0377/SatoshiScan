//
//  ThemeSelectionViewController.swift
//  SatoshiScan
//
//  Created by Aman on 18/2/25.
//

import UIKit

class ThemeSelectionViewController: UIViewController {
    
    private let tableView = UITableView()
    private let themes = ["System", "Light", "Dark"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Theme"
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
extension ThemeSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let theme = themes[indexPath.row]
        
        cell.textLabel?.text = theme
        
        let selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "System"
        cell.accessoryType = (theme == selectedTheme) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTheme = themes[indexPath.row]
        
        UserDefaults.standard.setValue(selectedTheme, forKey: "selectedTheme")
        
        tableView.reloadData()
        
        applyTheme(selectedTheme)
        
        navigationController?.popViewController(animated: true)
    }
    
    private func applyTheme(_ theme: String) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first })
            .first else { return }
        
        switch theme {
        case "Light":
            window.overrideUserInterfaceStyle = .light
        case "Dark":
            window.overrideUserInterfaceStyle = .dark
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}
