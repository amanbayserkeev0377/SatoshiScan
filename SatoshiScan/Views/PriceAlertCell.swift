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
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        contentView.addSubview(shadowView)
        shadowView.addSubview(coinImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(targetLabel)
        contentView.addSubview(alertSwitch)
        
        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            shadowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shadowView.widthAnchor.constraint(equalToConstant: 40),
            shadowView.heightAnchor.constraint(equalToConstant: 40),
            
            coinImageView.centerXAnchor.constraint(equalTo: shadowView.centerXAnchor),
            coinImageView.centerYAnchor.constraint(equalTo: shadowView.centerYAnchor),
            coinImageView.widthAnchor.constraint(equalTo: shadowView.widthAnchor),
            coinImageView.heightAnchor.constraint(equalTo: shadowView.heightAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: alertSwitch.leadingAnchor, constant: -12),
            
            targetLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            targetLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
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
