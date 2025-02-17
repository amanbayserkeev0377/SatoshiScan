//
//  PortfolioCell.swift
//  SatoshiScan
//
//  Created by Aman on 16/2/25.
//

import UIKit
import SDWebImage

class PortfolioCell: UITableViewCell {
    static let identifier = "PortfolioCell"
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        infoStackView.addArrangedSubview(priceLabel)
        infoStackView.addArrangedSubview(amountLabel)
        
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(infoStackView)
        
        contentView.addSubview(coinImageView)
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            coinImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coinImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            mainStackView.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with coin: PortfolioCoin) {
            nameLabel.text = coin.name
            priceLabel.text = "$\(String(format: "%.2f", coin.currentPrice))"
            amountLabel.text = "Amount: \(coin.amount)"
            coinImageView.sd_setImage(with: URL(string: coin.imageURL ?? ""), placeholderImage: UIImage(systemName: "bitcoinsign.circle"))
        }
    
    func updatePrice(newPrice: Double) {
        let oldPrice = Double(priceLabel.text?.replacingOccurrences(of: "$", with: "") ?? "0") ?? 0.0
        
        let color: UIColor = newPrice > oldPrice ? .systemGreen : .systemRed
        
        UIView.transition(with: priceLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.priceLabel.text = String(format: "$%.2f", newPrice)
            self.priceLabel.textColor = color
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.3) {
                    self.priceLabel.textColor = .gray
                }
            }
        }
    }
}

