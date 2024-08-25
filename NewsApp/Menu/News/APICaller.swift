import Foundation

final class APICaller {
    static let shared = APICaller()
    
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
    
    // Func: getTopStories
    public func getTopStories(page: Int, pageSize: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)&paging=\(page)&pageSize=\(pageSize)"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("apikey 2M8WkhLE9EDcBP5nu2YTBS:07mCYXY6m79lMey7pcXbm5", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
            } else if let data = data {
                do {
                    // JSON'u decode etmeden önce loglamak
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)")
                    }
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.result))
                } catch {
                    completion(.failure(APIError.decodingError))
                    print(error.localizedDescription)
                }
            } else {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
    
    // Function: searchWithText
    func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        // Sorgunun boş olup olmadığını kontrol et
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        // Sorguyu URL ile uyumlu hale getir
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(Constants.baseURL)&q=\(encodedQuery)"
        
        // URL'nin geçerli olup olmadığını kontrol et
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        // İstek oluştur ve başlat
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("apikey 2M8WkhLE9EDcBP5nu2YTBS:07mCYXY6m79lMey7pcXbm5", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print("Error: \(error.localizedDescription)")
            } else if let data = data {
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)") // API'den gelen veriyi logla
                    }
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.result))
                } catch {
                    completion(.failure(APIError.decodingError))
                    print("Decoding Error: \(error.localizedDescription)")
                }
            } else {
                completion(.failure(APIError.failedToGetData))
            }
        }
        task.resume()
    }
}

// Models
struct APIResponse: Codable {
    let success: Bool
    let result: [Article]
}

// Article model
struct Article: Codable {
    let key: String
    let url: String?
    let description: String
    let image: String
    let name: String
    let source: String
}
