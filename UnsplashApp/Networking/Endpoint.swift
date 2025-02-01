import Foundation

enum Endpoint {
    case photos(page: Int)
    case search(query: String, page: Int)
    
    var path: String {
        switch self {
        case .photos(let page):
            return "/photos?page=\(page)&per_page=20"
        case .search(let query, let page):
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            return "/search/photos?query=\(encodedQuery)&page=\(page)&per_page=20"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .photos, .search:
            return .GET
        }
    }
}

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
} 