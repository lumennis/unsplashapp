//
//  Photo.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//


import Foundation

struct Photo: Codable {
    let id: String
    let width: Int
    let height: Int
    let urls: PhotoURLs
    let user: User
    let likes: Int
    let description: String?
    let location: Location?
    let downloads: Int?
    
    struct PhotoURLs: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    struct User: Codable {
        let name: String
        let username: String
    }
    
    struct Location: Codable {
        let city: String?
        let country: String?
    }
}

extension Photo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
    
    func calculateImageHeight (scaledToWidth: CGFloat) -> CGFloat {
        let oldWidth = CGFloat(width)
        let scaleFactor = scaledToWidth / oldWidth
        let newHeight = CGFloat(height) * scaleFactor
        return newHeight
    }
}

struct SearchResponse: Codable {
    let total: Int
    let totalPages: Int
    let results: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}
