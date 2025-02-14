//
//  CryptoDetailViewController.swift
//  SatoshiScan
//
//  Created by Aman on 13/2/25.
//

import UIKit
import SDWebImage
import DGCharts

class CryptoDetailViewController: UIViewController {
    private let coin: Crypto
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chartView: LineChartView = {
        let chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.clipsToBounds = true
        chart.isHidden = true
        return chart
    }()
    
    private let addToPortfolioButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Add to Portfolio"
        config.baseBackgroundColor = .red
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.buttonSize = .large
        
        let button = UIButton(configuration: config)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(coin: Crypto) {
        self.coin = coin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("CryptoDetailViewController loaded!")
        view.backgroundColor = .systemBackground
        setupUI()
        configureData()
        fetchChartData()
        view.addSubview(addToPortfolioButton)

        
        addToPortfolioButton.addTarget(self, action: #selector(addToPortfolioTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(coinImageView)
        view.addSubview(nameLabel)
        view.addSubview(priceLabel)
        view.addSubview(chartView)
        view.addSubview(addToPortfolioButton)
        print("✅ addToPortfolioButton added to view:", addToPortfolioButton.superview != nil ? "YES" : "NO")

        
        print("setupUI() called")
        
        addToPortfolioButton.isHidden = false
        
        NSLayoutConstraint.activate([
            coinImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            coinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coinImageView.widthAnchor.constraint(equalToConstant: 100),
            coinImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            chartView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 250),
            
            addToPortfolioButton.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 20),
            addToPortfolioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addToPortfolioButton.heightAnchor.constraint(equalToConstant: 50),
            addToPortfolioButton.widthAnchor.constraint(equalToConstant: 200),
        ])
    }

    private func configureData() {
        nameLabel.text = "\(coin.name) (\(coin.symbol.uppercased()))"
        priceLabel.text = "$\(coin.current_price)"
        coinImageView.sd_setImage(with: URL(string: coin.image), placeholderImage: UIImage(systemName: "bitcoinsign.circle"))
    }
    
    private func fetchChartData() {
        CoinGeckoAPI.fetchMarketChart(for: coin.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chartEntries):
                    self?.updateChart(with: chartEntries)
                case .failure(let error):
                    print("Error fetching chart data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateChart(with entries: [ChartDataEntry]) {
        let dataSet = LineChartDataSet(entries: entries, label: "Price History")
        dataSet.colors = [.systemBlue]
        dataSet.circleColors = [.systemBlue]
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }
    
    @objc private func addToPortfolioTapped() {
        CoreDataManager.shared.addToPortfolio(coin: coin)
        let alert = UIAlertController(title: "Success", message: "\(coin.name) added to portfolio!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
