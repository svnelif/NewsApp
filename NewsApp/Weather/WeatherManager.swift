import Foundation
import CoreLocation
import WeatherKit

class WeatherManager {
    static let shared = WeatherManager()
    let service = WeatherService.shared
    
    func currentWeather(for location: CLLocation) async -> CurrentWeather? {
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(for: location, including: .current)
            return forecast
        }.value
        return currentWeather
    }
}
