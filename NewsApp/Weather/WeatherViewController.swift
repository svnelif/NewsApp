import UIKit
import SideMenu
import CoreLocation

class WeatherViewController: UIViewController, MenuListControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    var models = [DailyWeather]()
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    //Menu
    var menu: SideMenuNavigationController?
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter city name"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Weather"
        
        //Register 2 cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        setupMenu()
        setupLocation()
        setupSearchBar()
        requestWeatherForLocation()
    }
    //Location
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //Konum erişim izni
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let apiKey = "62836853957d7ca33cd5bb5d8436b269"
        let url = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(long)&exclude={part}&appid=\(apiKey)"
        
        URLSession.shared.dataTask(with: URL(string: url)! , completionHandler: { data, response, error in
            //Validation
            guard let data = data, error == nil else {
                print("Something went wrong.")
                return
            }
            //Convert data to models/Some object
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
            }
            catch{
                print("Error: \(error)")
            }
            guard let result = json else {
                return
            }
            let entries = result.daily
            self.models.append(contentsOf: entries)
            
            //Update user interface
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }).resume()
    }
    
    
    //Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        return cell
    }
    
    // Menu
    func setupMenu() {
        var menuItem = MenuListController(with: SideMenuItem.allCases)
        menu = SideMenuNavigationController(rootViewController: menuItem)
        
        menuItem.delegate = self
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: true)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
    
    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
            //self?.title = named.rawValue
            var viewController: UIViewController?
            switch named {
            case .language:
                viewController = SettingsViewController()
            }
            if let vc = viewController {
                self?.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func didWeather(_ sender: Any) {
        present(menu!, animated: true)
    }
    
    //Search Bar
    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        // Layout constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
}

struct WeatherResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: CurrentWeather
    let minutely: [MinutelyWeather]
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
    let alerts: [WeatherAlert]?
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, timezone, current, minutely, hourly, daily, alerts
        case timezoneOffset = "timezone_offset"
    }
}

struct CurrentWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double
    let weather: [WeatherDescription]
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp, pressure, humidity, clouds, visibility, weather
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case uvi
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
}

struct MinutelyWeather: Codable {
    let dt: Int
    let precipitation: Double
}

struct HourlyWeather: Codable {
    let dt: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double
    let weather: [WeatherDescription]
    let pop: Double
    
    enum CodingKeys: String, CodingKey {
        case dt, temp, pressure, humidity, clouds, visibility, weather, pop
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case uvi
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
    }
}

struct DailyWeather: Codable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let moonrise: Int
    let moonset: Int
    let moonPhase: Double
    let summary: String
    let temp: Temperature
    let feelsLike: FeelsLikeTemperature
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double
    let weather: [WeatherDescription]
    let clouds: Int
    let pop: Double
    let rain: Double?
    let uvi: Double
    
    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, moonrise, moonset, summary, temp, pressure, humidity, clouds, weather, pop, rain, uvi
        case moonPhase = "moon_phase"
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case feelsLike = "feels_like"
    }
}

struct Temperature: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct FeelsLikeTemperature: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct WeatherDescription: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherAlert: Codable {
    let senderName: String
    let event: String
    let start: Int
    let end: Int
    let description: String
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case senderName = "sender_name"
        case event, start, end, description, tags
    }
}

    /*
    
    @IBOutlet weak var weatherTableView: UITableView!
    
    var weatherData: [Weather] = []
    
    private let weatherLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var menu: SideMenuNavigationController?
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter city name"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weather".localized
        setupMenu()
        setupSearchBar()
        fetchWeatherData()
        setupTableView()
        
        view.addSubview(weatherLabel)
           
           // Etiket için yerleşim kısıtlamaları
           NSLayoutConstraint.activate([
               weatherLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
               weatherLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               weatherLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
           ])
    }
    func setupTableView() {
        weatherTableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
        weatherTableView.separatorStyle = .none // Hücreler arasında çizgi göstermemek için
    }
    
    func fetchWeatherData() {
            let headers = [
                "content-type": "application/json",
                "authorization": "apikey YOUR_VALID_API_KEY" // Gerçek API anahtarını buraya ekle
            ]
            
            let url = "https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=ankara"
            var request = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let WeatherForecast = try decoder.decode(WeatherForecast.self, from: data)
                    
                    if WeatherForecast.success == 1 {
                        self.weatherData = WeatherForecast.result
                        DispatchQueue.main.async {
                            self.weatherTableView.reloadData()
                        }
                    } else {
                        print("API Error: \(WeatherForecast.city)") // Mesajdan `message` alındığında düzenle
                    }
                    
                } catch let parsingError {
                    print("Error parsing JSON: \(parsingError.localizedDescription)")
                }
            }
            
            dataTask.resume()
        }
    
    //Search Bar
    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        // Layout constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else {
            print("Please enter a city name")
            return
        }
        
        // Klavyeyi kapat
        searchBar.resignFirstResponder()
        
        // Girilen şehir için hava durumu verilerini çek
        APIWeather.shared.getTopWeather(city: city) { [weak self] result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    // Hava durumu verilerini UI'ye göster
                    if let weather = weatherData.first {
                        self?.weatherLabel.text = "\(weather.day) - \(weather.degree)°C\nDurum: \(weather.description)"
                    } else {
                        self?.weatherLabel.text = "Veri bulunamadı."
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    // Hata durumunu ele al
                    self?.weatherLabel.text = "Hava durumu verileri alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }

    //Weather
    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
            //self?.title = named.rawValue
            var viewController: UIViewController?
            switch named {
            case .language:
                viewController = SettingsViewController()
            }
            if let vc = viewController {
                self?.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    func setupMenu() {
        var menuItem = MenuListController(with: SideMenuItem.allCases)
        menu = SideMenuNavigationController(rootViewController: menuItem)
        
        menuItem.delegate = self
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: true)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
    
    @IBAction func didWeather(_ sender: Any) {
        present(menu!, animated: true)
    }
    
    
}

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell
        let weatherDay = weatherData[indexPath.row]
        
        cell.dateLabel.text = "\(weatherDay.date) - \(weatherDay.day)"
        cell.degreeLabel.text = "\(weatherDay.degree)°C"
        cell.descriptionLabel.text = weatherDay.description
        
        if let url = URL(string: weatherDay.icon) {
            if let data = try? Data(contentsOf: url) {
                cell.weatherImageView.image = UIImage(data: data)
            }
        }
        
        return cell
    }
}

*/
