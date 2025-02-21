//
//  CryptoCell.swift
//  SatoshiScan
//
//  Created by Aman on 13/2/25.
//

import UIKit
import SDWebImage

class CryptoCell: UITableViewCell {
    static let identifier = "CryptoCell"
    
    private var isFavorite: Bool = false
    private var crypto: Crypto?
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .right
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [coinImageView, nameLabel, symbolLabel, priceLabel, favoriteButton, changeLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            coinImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coinImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coinImageView.widthAnchor.constraint(equalToConstant: 40),
            coinImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),
            
            symbolLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            symbolLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: priceLabel.leadingAnchor, constant: -8),
            symbolLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            
            priceLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -12),
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            changeLabel.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            changeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            changeLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    // MARK: - Favorite
    
    @objc private func favoriteTapped() {
        guard let coin = crypto else { return }
        
        isFavorite.toggle()
        favoriteButton.setImage(UIImage(systemName: isFavorite ? "star.fill" : "star"), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemYellow : .gray
        
        if isFavorite {
            CoreDataManager.shared.addToWatchList(coin: coin)
        } else {
            CoreDataManager.shared.removeFromWatchlist(coin: coin)
        }
    }
    
    // MARK: - Configure
    
    func configure(with coin: Crypto) {
        self.crypto = coin
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol.uppercased()
        priceLabel.text = String(format: "$%.2f", coin.current_price)
        
        
        coinImageView.sd_setImage(with: URL(string: coin.image), placeholderImage: UIImage(systemName: "bitcoinsign.circle"))
        
        isFavorite = CoreDataManager.shared.isInWatchlist(coin: coin)
        favoriteButton.setImage(UIImage(systemName: isFavorite ? "star.fill" : "star"), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemYellow : .gray
        
        updateChangeLabel(changePercentage: coin.price_change_percentage_24h)
    }
    
    func updatePrice(newPrice: Double, changePercentage: Double) {
        DispatchQueue.main.async {
            UIView.transition(with: self.priceLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.priceLabel.text = String(format: "$%.2f", newPrice)
            }, completion: nil)
            
            UIView.transition(with: self.changeLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.updateChangeLabel(changePercentage: changePercentage)
            }, completion: nil)
        }
    }
    
    private func updateChangeLabel(changePercentage: Double) {
        changeLabel.text = String(format: "%.2f%%", changePercentage)
        
        if changePercentage == 0.00 {
            changeLabel.textColor = .gray
            changeLabel.backgroundColor = .clear
        } else {
            let color: UIColor = changePercentage > 0 ? .systemGreen : .systemRed
            changeLabel.textColor = color
            changeLabel.backgroundColor = color.withAlphaComponent(0.2)
        }
    }
    
    private func animatePriceChange(color: UIColor) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.priceLabel.textColor = color
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.priceLabel.textColor = .label
            }
        }
    }
}
