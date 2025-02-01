//
//  PhotosViewController.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

final class PhotosViewController: UIViewController {
    
    private enum Section { case main }
    
    private let viewModel: PhotosViewModel
    weak var coordinator: Coordinator?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search photos"
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        return controller
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = PhotosLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.delegate = self
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    init(viewModel: PhotosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupUI()
        setupNavigationBar()
        viewModel.loadPhotosData()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Photos"
    }
    
    private func setupUI() {
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
        collectionView.pinToEdges(of: view)
    }
    
    private func setupDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Photo>(
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc private func refreshData() {
        viewModel.refresh()
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.photos, toSection: .main)
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        DispatchQueue.main.async { [weak self] in
            self?.dataSource.apply(snapshot, animatingDifferences: false) {
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
}

// MARK: - PhotosViewModelDelegate

extension PhotosViewController: PhotosViewModelDelegate {
    func photosDidUpdate() {
        updateDataSource()
        refreshControl.endRefreshing()
    }
    
    func showError(_ error: Error) {}
}

// MARK: - UICollectionViewDelegate

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = viewModel.photo(at: indexPath) else { return }
        coordinator?.showPhotoDetail(photo, from: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2 {
            viewModel.loadPhotosData()
        }
    }
}

// MARK: - UISearchBarDelegate

extension PhotosViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.cancelSearch()
    }
}

// MARK: - PhotosLayoutDelegate

extension PhotosViewController: PhotosLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, cellWidth: CGFloat) -> CGFloat {
        guard let photo = viewModel.photo(at: indexPath) else { return 180 }
        return photo.calculateImageHeight(scaledToWidth: cellWidth)
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func idForItem(at indexPath: IndexPath) -> String {
        return viewModel.photo(at: indexPath)?.id ?? ""
    }
}
