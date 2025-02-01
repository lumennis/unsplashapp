//
//  NetworkManager.swift
//  UnsplashApp
//
//  Created by Yevhen on 31.01.2025.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func downloadImage(from url: URL) async throws -> Data
}

final class NetworkManager: NetworkManagerProtocol {
    private let baseURL = "https://api.unsplash.com"
    private let accessKey = "64FPyDSnlTkrSTLE9SBMUBReyUpNa6SUI_1BJfjayOM"
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.invalidData
        }
    }
    
    func downloadImage(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
} 
