//
//  FavoritesViewController.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

final class FavoritesViewController: UIViewController {
    private enum Section { case main }
    
    weak var coordinator: Coordinator?
    private let favoritesService: FavoritesServiceProtocol
    
    private var photos: [Photo] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Photo> = {
        let dataSource = UICollectionViewDiffableDataSource<Section, Photo>(
            collectionView: collectionView
        ) { collectionView, indexPath, photo in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoCell.reuseIdentifier,
                for: indexPath
            ) as? PhotoCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: photo)
            return cell
        }
        return dataSource
    }()
    
    init(favoritesService: FavoritesServiceProtocol = FavoritesService.shared) {
        self.favoritesService = favoritesService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePhotos()
    }
    
    private func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.pinToEdges(of: view)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalWidth(0.5)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
    
    private func updatePhotos() {
        photos = favoritesService.getFavorites()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(photos)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = dataSource.itemIdentifier(for: indexPath) else { return }
        coordinator?.showPhotoDetail(photo, from: self)
    }
} 
