//
//  PhotoDetailViewController.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//
import UIKit

final class PhotoDetailViewController: UIViewController {
    private enum Section: Int {
        case image
        case info
    }
    
    private enum InfoRow: Int, CaseIterable {
        case author
        case likes
        case location
        case downloads
        
        var title: String {
            switch self {
            case .author: return "Author"
            case .likes: return "Likes"
            case .location: return "Location"
            case .downloads: return "Downloads"
            }
        }
    }
    
    private let photo: Photo
    private let networkManager: NetworkManagerProtocol
    private let favoritesService: FavoritesServiceProtocol
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: PhotoTableViewCell.reuseIdentifier)
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: InfoTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(photo: Photo, networkManager: NetworkManagerProtocol, favoritesService: FavoritesServiceProtocol = FavoritesService.shared) {
        self.photo = photo
        self.networkManager = networkManager
        self.favoritesService = favoritesService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateLikeButtonState()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
        
        view.addSubview(tableView)
        tableView.pinToEdges(of: view)
    }
    
    private func updateLikeButtonState() {
        likeButton.isSelected = favoritesService.isFavorite(photo)
    }
    
    @objc private func likeButtonTapped() {
        if favoritesService.isFavorite(photo) {
            favoritesService.removeFavorite(photo)
        } else {
            favoritesService.addFavorite(photo)
        }
        updateLikeButtonState()
    }
}

// MARK: - UITableViewDataSource
extension PhotoDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .image:
            return 1
        case .info:
            return InfoRow.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .image:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PhotoTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! PhotoTableViewCell
            cell.configure(with: photo, networkManager: networkManager)
            return cell
            
        case .info:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: InfoTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! InfoTableViewCell
            
            guard let infoRow = InfoRow(rawValue: indexPath.row) else {
                return UITableViewCell()
            }
            
            let value: String = {
                switch infoRow {
                case .author:
                    return photo.user.name
                case .likes:
                    return "\(photo.likes)"
                case .location:
                    return [photo.location?.city, photo.location?.country]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                case .downloads:
                    return "\(photo.downloads ?? 0)"
                }
            }()
            
            cell.configure(title: infoRow.title, value: value)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension PhotoDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else { return 0 }
        
        switch section {
        case .image:
            let width = tableView.bounds.width
            return width * CGFloat(photo.height) / CGFloat(photo.width)
        case .info:
            return UITableView.automaticDimension
        }
    }
} 
