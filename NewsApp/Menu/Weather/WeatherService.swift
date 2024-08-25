//import Foundation
//
//class WeatherService {
//
//    static let shared = WeatherService()
//
//    func getWeather(for cityName: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=YOUR_API_KEY&units=metric"
//        
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
//                return
//            }
//
//            do {
//                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
//                completion(.success(weatherResponse))
//            } catch let decodeError {
//                completion(.failure(decodeError))
//            }
//        }
//
//        task.resume()
//    }
//}
//
