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
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(coinImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            coinImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coinImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coinImageView.widthAnchor.constraint(equalToConstant: 40),
            coinImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with coin: Crypto) {
        nameLabel.text = "\(coin.name) (\(coin.symbol.uppercased()))"
        priceLabel.text = "$\(coin.current_price)"
        coinImageView.sd_setImage(with: URL(string: coin.image), placeholderImage: UIImage(systemName: "bitcoinsign.circle"))
    }
}
