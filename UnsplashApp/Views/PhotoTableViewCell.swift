//
//  PhotoTableViewCell.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

final class PhotoTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PhotoTableViewCell"
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var imageLoadTask: Task<Void, Never>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        photoImageView.image = nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(photoImageView)
        photoImageView.pinToEdges(of: contentView)
    }
    
    func configure(with photo: Photo, networkManager: NetworkManagerProtocol) {
        imageLoadTask?.cancel()
        
        imageLoadTask = Task {
            guard let url = URL(string: photo.urls.regular) else { return }
            do {
                let data = try await networkManager.downloadImage(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        photoImageView.image = image
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
} 
