//
//  PhotosViewModel.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import Foundation

protocol PhotosViewModelDelegate: AnyObject {
    func photosDidUpdate()
    func showError(_ error: Error)
}

final class PhotosViewModel {
    
    weak var delegate: PhotosViewModelDelegate?
    
    private let networkManager: NetworkManagerProtocol
    private(set) var photos: [Photo] = []
    private var currentPage = 1
    private var isLoading = false
    private var searchText: String?
    private var searchTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func loadPhotosData() {
        Task {
            await loadPhotos()
        }
    }
    
    private func loadPhotos() async {
        guard !isLoading else { return }
        isLoading = true
        fetchTask?.cancel()
        
        fetchTask = Task {
            do {
                let searchQuery = searchText
                let page = currentPage
                
                let fetchedPhotos: [Photo] = try await {
                    if let query = searchQuery {
                        let response: SearchResponse = try await networkManager.fetch(.search(query: query, page: page))
                        return response.results
                    } else {
                        return try await networkManager.fetch(.photos(page: page))
                    }
                }()
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    
                    if self.currentPage == 1 {
                        self.photos = fetchedPhotos
                    } else {
                        self.photos.append(contentsOf: fetchedPhotos)
                        self.photos.removeDuplicates()
                    }
                    self.currentPage += 1
                    self.delegate?.photosDidUpdate()
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.delegate?.showError(error)
                }
            }
            isLoading = false
        }
    }
    
    func refresh() {
        currentPage = 1
        loadPhotosData()
    }
    
    func updateSearchText(_ text: String?) {
        searchText = text
        searchTask?.cancel()
        searchTask = nil
        searchTask = Task {
            do {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                try Task.checkCancellation()
                currentPage = 1
                await loadPhotos()
            } catch {
                print(error)
            }
        }
    }
    
    func cancelSearch() {
        searchText = nil
        currentPage = 1
        loadPhotosData()
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        guard indexPath.item < photos.count else { return nil }
        return photos[indexPath.item]
    }
    
    deinit {
        searchTask?.cancel()
        fetchTask?.cancel()
    }
}
