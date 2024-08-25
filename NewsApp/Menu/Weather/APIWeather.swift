//import Foundation
//
//final class APIWeather {
//    static let shared = APIWeather()
//    
//    // Struct: Constants
//    struct Constants {
//        static let baseURL = "https://api.collectapi.com/weather/getWeather?data.lang=tr"
//        static let apiKey = "2M8WkhLE9EDcBP5nu2YTBS:07mCYXY6m79lMey7pcXbm5"
//    }
//    
//    private init() {}
//    
//    enum APIError: Error {
//        case failedToGetData
//        case invalidURL
//        case decodingError
//        case unknownError
//    }
//    
//    public func getTopWeather(city: String, completion: @escaping (Result<[Weather], Error>) -> Void) {
//
//        let headers = [
//          "content-type": "application/json",
//          "authorization": "apikey 2M8WkhLE9EDcBP5nu2YTBS:07mCYXY6m79lMey7pcXbm5"
//        ]
//
//        let url = "https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=ankara"
//        var request = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("HTTP Response Code: \(httpResponse.statusCode)")
//            }
//
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//
//            do {
//                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    if let success = jsonResponse["success"] as? Int, success == 0 {
//                        print("Error: \(jsonResponse["message"] ?? "Unknown error")")
//                    } else {
//                        print("Response JSON: \(jsonResponse)")
//                    }
//                }
//            } catch let parsingError {
//                print("Error parsing JSON: \(parsingError.localizedDescription)")
//            }
//        }
//
//        dataTask.resume()
//
//    }
//}
