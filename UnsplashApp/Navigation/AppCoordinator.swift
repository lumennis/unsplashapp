//
//  AppCoordinator.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
    func showPhotoDetail(_ photo: Photo, from: UIViewController)
}

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let networkManager: NetworkManagerProtocol
    private let tabBarController: UITabBarController
    
    init(navigationController: UINavigationController, networkManager: NetworkManagerProtocol) {
        self.navigationController = navigationController
        self.networkManager = networkManager
        self.tabBarController = UITabBarController()
    }
    
    func start() {
        setupTabBar()
    }
    
    private func setupTabBar() {
        let photosViewModel = PhotosViewModel(networkManager: networkManager)
        let photosVC = PhotosViewController(viewModel: photosViewModel)
        photosVC.coordinator = self
        let photosNav = UINavigationController(rootViewController: photosVC)
        photosNav.tabBarItem = UITabBarItem(title: "Photos", image: UIImage(systemName: "photo.on.rectangle"), tag: 0)
        
        let favoritesVC = FavoritesViewController()
        favoritesVC.coordinator = self
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 1)
        
        tabBarController.viewControllers = [photosNav, favoritesNav]
        navigationController.navigationBar.isHidden = true
        navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    func showPhotoDetail(_ photo: Photo, from: UIViewController) {
        let detailVC = PhotoDetailViewController(photo: photo, networkManager: networkManager)
        let navController = from.navigationController ?? navigationController
        navController.pushViewController(detailVC, animated: true)
    }
} 
