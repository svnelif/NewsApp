import Foundation

final class APIWeather {
    static let shared = APIWeather()
    
    // Struct: Constants
    struct Constants {
        static let baseURL = "https://api.collectapi.com/news/getNews?country=tr&tag=general"
    }
    
    private init() {}
    
    
    enum APIError: Error {
        case failedToGetData
        case invalidURL
        case decodingError
        case unknownError
    }
    

}
