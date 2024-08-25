//
//  RequestManager.swift
//

import Foundation
import Alamofire


class RequestManager {
    static let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=42.70&longitude=23.42&current_weather=true")
    
    static var temperature: Double = 0.0
    
    class func fetchData() {
        var request = URLRequest(url: url!) //Create the URLRequest
        request.httpMethod = "GET" //Set the method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // set the content type as there are APIs supporting multiple content types
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data, let weather = try? JSONDecoder.snakeCaseDecoder.decode(Weather.self, from: data) else {
                print("Incorrect format")
                return
        }
            print(weather)
            RequestManager.temperature = weather.currentWeather.temperature
            
            NotificationCenter.default.post(name: .newDataAvailable, object: nil)
            
        })
        task.resume()
    }
    
    class func fetchDataAlamofire() {
        let url = "https://api.open-meteo.com/v1/forecast?latitude=42.70&longitude=23.42&current_weather=true"
        
        AF.request(url).responseDecodable(of: WeatherRealm.self) { response in
            guard let weatherData = response.value else {
                return
            }
            
            let location = Locations()
            location.name = "Sofia"
            location.weather = weatherData
            
            
            DispatchQueue.main.async {
                try? LocalDataManager.realm.write {
                    LocalDataManager.realm.add(location, update: .all)
                }
                LocalDataManager.getWeatherData()
            }
            
            print(weatherData)
        }
        
    }
    
}
