import Foundation

final class APICaller {
    static let shared = APICaller()
    
    // Struct: Constants
    struct Constants {
        static let baseURL = "https://api.collectapi.com/news/getNews?country=tr&tag=general"
    }

    private init() {}
    
    // Func: getTopStories
    public func getTopStories(page: Int, pageSize: Int, completion: @escaping (Result<[Article], Error>) -> Void) {
        let urlString = "\(Constants.baseURL)&paging=\(page)"
        guard let url = URL(string: urlString) else {
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
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.result))
                } catch {
                    completion(.failure(error))
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    // Function: searchWithText
    func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(Constants.baseURL)&q=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("apikey 2M8WkhLE9EDcBP5nu2YTBS:07mCYXY6m79lMey7pcXbm5", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                print("Error: \(error.localizedDescription)")
            } else if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.success(result.result))
                } catch {
                    completion(.failure(error))
                    print("Decoding Error: \(error.localizedDescription)")
                }
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
