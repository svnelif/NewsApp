/*
import Foundation
import CoreLocation

enum WeatherError: Error {
    case invalidURL
    case networkError(Error)
    case noData
    case decodingError(Error)
}

enum ServiceError: String, Error {
    case serverError = "Check your network connection"
    case decodingError = "Decoding Error"
}

struct WeatherService {
    private let baseURL = "https://api.collectapi.com/weather/getWeather"
    private let apiKey = "2M8WkhLE9EDcBP5nu2YTBS:07mCYXY6m79lMey7pcXbm5"
    
    func fetchWeatherCityName(forCityName cityName: String, completion: @escaping(Result<[WeatherEntry], ServiceError>) -> Void) {
        let urlString = "\(baseURL)?data.lang=tr&data.city=\(cityName)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.serverError))
            return
        }
        fetchWeather(url: url, completion: completion)
    }
    
    func fetchWeatherByCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Result<[WeatherEntry], WeatherError>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=YOUR_API_KEY&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                    let weatherEntries = weatherResponse.weatherEntries
                    completion(.success(weatherEntries))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
    
    private func fetchWeather(url: URL, completion: @escaping(Result<[WeatherEntry], ServiceError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("apikey \(apiKey)", forHTTPHeaderField: "authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.serverError))
                    return
                }
                guard let data = data else {
                    completion(.failure(.serverError))
                    return
                }
                guard let weatherModel = self.parseJSON(data: data) else {
                    completion(.failure(.decodingError))
                    return
                }
                completion(.success(weatherModel.result))
            }
        }.resume()
    }
    
    private func parseJSON(data: Data) -> WeatherModel? {
        do {
            let result = try JSONDecoder().decode(WeatherModel.self, from: data)
            return result
        } catch {
            print("Error decoding data: \(error)")
            return nil
        }
    }
}

// Bu örnekte WeatherResponse şu şekilde tanımlanmıştır:
struct WeatherResponse: Codable {
    let result: [WeatherEntry]
    
    var weatherEntries: [WeatherEntry] {
        return result
    }
}
*/
