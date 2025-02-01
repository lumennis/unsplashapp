//
//  FavoritesService.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import Foundation

protocol FavoritesServiceProtocol {
    func addFavorite(_ photo: Photo)
    func removeFavorite(_ photo: Photo)
    func isFavorite(_ photo: Photo) -> Bool
    func getFavorites() -> [Photo]
}

final class FavoritesService: FavoritesServiceProtocol {
    static let shared = FavoritesService()
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorites"
    
    private init() {}
    
    private var favorites: [Photo] {
        get {
            guard let data = userDefaults.data(forKey: favoritesKey),
                  let photos = try? JSONDecoder().decode([Photo].self, from: data) else {
                return []
            }
            return photos
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
    
    func addFavorite(_ photo: Photo) {
        var currentFavorites = favorites
        if !currentFavorites.contains(where: { $0.id == photo.id }) {
            currentFavorites.append(photo)
            favorites = currentFavorites
        }
    }
    
    func removeFavorite(_ photo: Photo) {
        var currentFavorites = favorites
        currentFavorites.removeAll { $0.id == photo.id }
        favorites = currentFavorites
    }
    
    func isFavorite(_ photo: Photo) -> Bool {
        favorites.contains { $0.id == photo.id }
    }
    
    func getFavorites() -> [Photo] {
        favorites
    }
} 
