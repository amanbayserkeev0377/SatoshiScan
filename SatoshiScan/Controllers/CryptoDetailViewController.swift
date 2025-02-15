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
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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
    
    private let priceChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let marketCapLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let volumeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chartView: LineChartView = {
        let chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.clipsToBounds = true
        
        chart.rightAxis.enabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.axisLineColor = .gray
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.drawGridLinesEnabled = false
        chart.legend.enabled = false
        
        chart.noDataText = "No chart data available"
        chart.noDataTextColor = .gray
        
        return chart
    }()
    
    private let addToPortfolioButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Add to Portfolio"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.buttonSize = .large
        
        let button = UIButton(configuration: config)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fetchChartData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.fetchCryptoDetail()
        }
        
        addToPortfolioButton.addTarget(self, action: #selector(addToPortfolioTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [
            coinImageView, nameLabel, priceLabel, chartView,
            priceChangeLabel, marketCapLabel, volumeLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        chartView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        contentView.addSubview(stackView)
        contentView.addSubview(addToPortfolioButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            chartView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            
            addToPortfolioButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            addToPortfolioButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addToPortfolioButton.heightAnchor.constraint(equalToConstant: 50),
            addToPortfolioButton.widthAnchor.constraint(equalToConstant: 200),
            
            contentView.bottomAnchor.constraint(equalTo: addToPortfolioButton.bottomAnchor, constant: 20)
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
                    print("✅ Chart data received: \(chartEntries.count) points")
                    self?.updateChart(with: chartEntries)
                case .failure(let error):
                    print("Error fetching chart data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateChart(with entries: [ChartDataEntry]) {
        print("📊 Updating chart with \(entries.count) data points")
        
        guard !entries.isEmpty else {
            print("No data for chart")
            chartView.data = nil
            return
        }

        let minX = entries.first?.x ?? 0
        let normalizedEntries = entries.map { ChartDataEntry(x: $0.x - minX, y: $0.y) }
        
        let dataSet = LineChartDataSet(entries: normalizedEntries, label: "Price History")
        dataSet.colors = [.systemBlue]
        dataSet.lineWidth = 2.0
        dataSet.drawCirclesEnabled = false
        dataSet.mode = .cubicBezier
        
        let gradientColors = [UIColor.systemBlue.cgColor, UIColor.clear.cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: [0.5, 1.0])!
        dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90.0)
        dataSet.drawFilledEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSet: dataSet)
        data.setDrawValues(false)
        
        print("📉 Setting chart data: \(entries.count) points")
        chartView.data = data
        chartView.notifyDataSetChanged()
        chartView.setNeedsDisplay()
        print("✅ Chart updated!")
    }
    
    @objc private func addToPortfolioTapped() {
        CoreDataManager.shared.addToPortfolio(coin: coin)
        let alert = UIAlertController(title: "Success", message: "\(coin.name) added to portfolio!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func fetchCryptoDetail() {
        CoinGeckoAPI.fetchCryptoDetail(for: coin.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let detail):
                    self?.updateDetailUI(with: detail)
                case .failure(let error):
                    print("Error fetching detail:", error.localizedDescription)
                }
            }
        }
    }
    
    private func updateDetailUI(with detail: CryptoDetail) {
        let priceChange = detail.market_data.price_change_percentage_24h ?? 0.0
        let marketCap = detail.market_data.market_cap?["usd"] ?? 0.0
        let volume = detail.market_data.total_volume?["usd"] ?? 0.0
        
        priceChangeLabel.text = "24h Change: \(String(format: "%.2f", priceChange))%"
        marketCapLabel.text = "Market Cap: $\(String(format: "%.0f", marketCap))"
        volumeLabel.text = "24h Volume: $\(String(format: "%.0f", volume))"
        
        priceChangeLabel.textColor = priceChange >= 0 ? .systemGreen : .systemRed
    }
}
