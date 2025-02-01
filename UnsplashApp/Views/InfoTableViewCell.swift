//
//  InfoTableViewCell.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

final class InfoTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "InfoTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.9)
        label.font = .boldSystemFont(ofSize: 16)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: Float(1000)), for: .horizontal)
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.9)
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
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
        selectionStyle = .none
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        contentView.addSubviews(stackView)
        stackView.pinToEdges(of: contentView, with: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}
