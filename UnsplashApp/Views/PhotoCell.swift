//
//  PhotoCell.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PhotoCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private var imageLoadTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageView.image = nil
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.pinToEdges(of: contentView)
    }
    
    func configure(with photo: Photo) {
        imageLoadTask?.cancel()
        
        imageLoadTask = Task {
            guard let url = URL(string: photo.urls.small) else { return }
            
            do {
                let data = try await URLSession.shared.data(from: url).0
                guard !Task.isCancelled else { return }
                
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        UIView.transition(
                            with: self.imageView,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                                self.imageView.image = image
                            }
                        )
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
