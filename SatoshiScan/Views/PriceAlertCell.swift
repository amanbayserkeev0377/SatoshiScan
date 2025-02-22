//
//  PriceAlertCell.swift
//  SatoshiScan
//
//  Created by Aman on 22/2/25.
//

import UIKit
import SDWebImage
import CoreData

class PriceAlertCell: UITableViewCell {
    static let identifier = "PriceAlertCell"
    
    private let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let alertSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    var switchAction: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [coinImageView, titleLabel, targetLabel, alertSwitch].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            coinImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coinImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coinImageView.widthAnchor.constraint(equalToConstant: 44),
            coinImageView.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: alertSwitch.leadingAnchor, constant: -12),
            
            targetLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            targetLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            targetLabel.trailingAnchor.constraint(lessThanOrEqualTo: alertSwitch.leadingAnchor, constant: -12),
            
            alertSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            alertSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        alertSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
    }
    
    func configure(with alert: PriceAlert) {
        titleLabel.text = "\(alert.symbol ?? "Unknown") Alert"
        targetLabel.text = "Target: $\(String(format: "%.2f", alert.targetPrice))"
        alertSwitch.isOn = alert.isEnabled
        
        if let imageURL = alert.imageURL, let url = URL(string: imageURL) {
            coinImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "bitcoinsign.circle"))
        } else {
            coinImageView.image = UIImage(systemName: "bitcoinsign.circle")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinImageView.image = UIImage(systemName: "bitcoinsign.circle")
        titleLabel.text = nil
        targetLabel.text = nil
        alertSwitch.isOn = false
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        switchAction?(sender.isOn)
    }
}
