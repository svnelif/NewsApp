import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private let apiKey = "62836853957d7ca33cd5bb5d8436b269"
    
    private var weatherResponse: WeatherResponse?
    
    // UI elemanları
    private let temperatureLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let cityLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // UI elemanlarını yapılandır
        temperatureLabel.font = UIFont.systemFont(ofSize: 24)
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        cityLabel.font = UIFont.systemFont(ofSize: 20)
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cityLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(descriptionLabel)
        
        // Auto Layout kuralları
        NSLayoutConstraint.activate([
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 20),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Konum güncellendiğinde çağrılır
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchWeatherData(lat: location.coordinate.latitude, long: location.coordinate.longitude)
    }
    
    private func fetchWeatherData(lat: Double, long: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&exclude=minutely&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching weather data: \(error)")
                return
            }
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                self.weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI()
                }
            } catch {
                print("Error decoding weather data: \(error)")
            }
        }
        
        task.resume()
    }
    
    private func updateUI() {
        guard let weatherResponse = weatherResponse else { return }
        
        let temperature = weatherResponse.main.temp
        let description = weatherResponse.weather.first?.description ?? "No description"
        let city = weatherResponse.name
        
        temperatureLabel.text = String(format: "%.1f°C", temperature - 273.15) // Convert from Kelvin to Celsius
        descriptionLabel.text = description.capitalized
        cityLabel.text = city
    }
}


//import UIKit
//import SideMenu
//import CoreLocation
//
//class WeatherViewController: UIViewController, MenuListControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
//
//    @IBOutlet var table: UITableView!
//    var models = [DailyWeather]()
//    var hourlyModels = [HourlyWeather]()
//
//    let locationManager = CLLocationManager()
//    var currentLocation: CLLocation?
//
//    //Menu
//    var menu: SideMenuNavigationController?
//    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.placeholder = "Enter city name"
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        return searchBar
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.title = "Weather"
//
//        //Register 2 cells
//        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
//        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
//
//        table.delegate = self
//        table.dataSource = self
//
//        table.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
//        view.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
//
//        setupMenu()
//        setupSearchBar()
//        setupLocation()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        setupLocation()
//    }
//
//    //Location
//    func setupLocation() {
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization() // Konum erişim izni
//        locationManager.startUpdatingLocation()
//    }
//
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .authorizedWhenInUse, .authorizedAlways:
//            // Kullanıcı izni verdi, konum güncellemelerini başlat
//            locationManager.startUpdatingLocation()
//        case .notDetermined, .restricted, .denied:
//            // İzin verilmediyse uygun bir işlem yap veya kullanıcıya bir mesaj göster
//            break
//        @unknown default:
//            break
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first, currentLocation == nil {
//            currentLocation = location
//            locationManager.stopUpdatingLocation()
//            requestWeatherForLocation()
//        }
//    }
//
//    func requestWeatherForLocation() {
//        guard let currentLocation = currentLocation else {
//            return
//        }
//        let long = currentLocation.coordinate.longitude
//        let lat = currentLocation.coordinate.latitude
//
//        print("\(long), \(lat)")
//        
//        let apiKey = "62836853957d7ca33cd5bb5d8436b269"
//        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&exclude=minutely&appid=\(apiKey)"
//
//        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
//            guard let data = data, error == nil else {
//                print("Something went wrong.")
//                return
//            }
//
//            do {
//                let result = try JSONDecoder().decode(WeatherResponse.self, from: data)
//                self.models = result.daily
//                self.current = result.current
//                self.hourlyModels = result.hourly
//
//                DispatchQueue.main.async {
//                    self.table.reloadData()
//                    self.table.tableFooterView = self.createTableHeader()
//                }
//            } catch {
//                print("Error: \(error)")
//            }
//        }).resume()
//    }
//
//    func createTableHeader() -> UIView {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
//        headerView.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
//
//        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
//        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
//        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))
//
//        headerView.addSubview(locationLabel)
//        headerView.addSubview(tempLabel)
//        headerView.addSubview(summaryLabel)
//
//        tempLabel.textAlignment = .center
//        locationLabel.textAlignment = .center
//        summaryLabel.textAlignment = .center
//
//        locationLabel.text = "Current Location"
//
//        guard let currentWeather = self.current else {
//            return UIView()
//        }
//
//        tempLabel.text = "\(currentWeather.temp)°"
//        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
//        summaryLabel.text = currentWeather.weather.first?.description
//
//        return headerView
//    }
//
//    // TableView Functions
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        }
//        return models.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
//            cell.configure(with: hourlyModels)
//            cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
//            return cell
//        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
//        cell.configure(with: models[indexPath.row])
//        cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//
//    // Menu
//    func setupMenu() {
//        let menuItem = MenuListController(with: SideMenuItem.allCases)
//        menu = SideMenuNavigationController(rootViewController: menuItem)
//
//        menuItem.delegate = self
//        menu?.leftSide = true
//        menu?.setNavigationBarHidden(true, animated: true)
//        SideMenuManager.default.leftMenuNavigationController = menu
//        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
//    }
//
//    func didSelectMenuItem(named: SideMenuItem) {
//        menu?.dismiss(animated: true, completion: { [weak self] in
//            var viewController: UIViewController?
//            switch named {
//            case .language:
//                viewController = SettingsViewController()
//            }
//            if let vc = viewController {
//                self?.present(vc, animated: true, completion: nil)
//            }
//        })
//    }
//
//    @IBAction func didWeather(_ sender: Any) {
//        present(menu!, animated: true)
//    }
//
//    //Search Bar
//    func
//
//    /*
//    
//    @IBOutlet weak var weatherTableView: UITableView!
//    
//    var weatherData: [Weather] = []
//    
//    private let weatherLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    var menu: SideMenuNavigationController?
//    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.placeholder = "Enter city name"
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        return searchBar
//    }()
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "Weather".localized
//        setupMenu()
//        setupSearchBar()
//        fetchWeatherData()
//        setupTableView()
//        
//        view.addSubview(weatherLabel)
//           
//           // Etiket için yerleşim kısıtlamaları
//           NSLayoutConstraint.activate([
//               weatherLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
//               weatherLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//               weatherLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//           ])
//    }
//    func setupTableView() {
//        weatherTableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherCell")
//        weatherTableView.separatorStyle = .none // Hücreler arasında çizgi göstermemek için
//    }
//    
//    func fetchWeatherData() {
//            let headers = [
//                "content-type": "application/json",
//                "authorization": "apikey YOUR_VALID_API_KEY" // Gerçek API anahtarını buraya ekle
//            ]
//            
//            let url = "https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=ankara"
//            var request = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
//            request.httpMethod = "GET"
//            request.allHTTPHeaderFields = headers
//            
//            let session = URLSession.shared
//            let dataTask = session.dataTask(with: request) { (data, response, error) in
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let data = data else {
//                    print("No data received")
//                    return
//                }
//                
//                do {
//                    let decoder = JSONDecoder()
//                    let WeatherForecast = try decoder.decode(WeatherForecast.self, from: data)
//                    
//                    if WeatherForecast.success == 1 {
//                        self.weatherData = WeatherForecast.result
//                        DispatchQueue.main.async {
//                            self.weatherTableView.reloadData()
//                        }
//                    } else {
//                        print("API Error: \(WeatherForecast.city)") // Mesajdan `message` alındığında düzenle
//                    }
//                    
//                } catch let parsingError {
//                    print("Error parsing JSON: \(parsingError.localizedDescription)")
//                }
//            }
//            
//            dataTask.resume()
//        }
//    
//    //Search Bar
//    func setupSearchBar() {
//        view.addSubview(searchBar)
//        searchBar.delegate = self
//        
//        // Layout constraints
//        NSLayoutConstraint.activate([
//            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let city = searchBar.text, !city.isEmpty else {
//            print("Please enter a city name")
//            return
//        }
//        
//        // Klavyeyi kapat
//        searchBar.resignFirstResponder()
//        
//        // Girilen şehir için hava durumu verilerini çek
//        APIWeather.shared.getTopWeather(city: city) { [weak self] result in
//            switch result {
//            case .success(let weatherData):
//                DispatchQueue.main.async {
//                    // Hava durumu verilerini UI'ye göster
//                    if let weather = weatherData.first {
//                        self?.weatherLabel.text = "\(weather.day) - \(weather.degree)°C\nDurum: \(weather.description)"
//                    } else {
//                        self?.weatherLabel.text = "Veri bulunamadı."
//                    }
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    // Hata durumunu ele al
//                    self?.weatherLabel.text = "Hava durumu verileri alınamadı: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//
//    //Weather
//    func didSelectMenuItem(named: SideMenuItem) {
//        menu?.dismiss(animated: true, completion: { [weak self] in
//            //self?.title = named.rawValue
//            var viewController: UIViewController?
//            switch named {
//            case .language:
//                viewController = SettingsViewController()
//            }
//            if let vc = viewController {
//                self?.present(vc, animated: true, completion: nil)
//            }
//        })
//    }
//    
//    func setupMenu() {
//        var menuItem = MenuListController(with: SideMenuItem.allCases)
//        menu = SideMenuNavigationController(rootViewController: menuItem)
//        
//        menuItem.delegate = self
//        menu?.leftSide = true
//        menu?.setNavigationBarHidden(true, animated: true)
//        SideMenuManager.default.leftMenuNavigationController = menu
//        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
//    }
//    
//    @IBAction func didWeather(_ sender: Any) {
//        present(menu!, animated: true)
//    }
//    
//    
//}
//
//extension WeatherViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return weatherData.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath) as! WeatherTableViewCell
//        let weatherDay = weatherData[indexPath.row]
//        
//        cell.dateLabel.text = "\(weatherDay.date) - \(weatherDay.day)"
//        cell.degreeLabel.text = "\(weatherDay.degree)°C"
//        cell.descriptionLabel.text = weatherDay.description
//        
//        if let url = URL(string: weatherDay.icon) {
//            if let data = try? Data(contentsOf: url) {
//                cell.weatherImageView.image = UIImage(data: data)
//            }
//        }
//        
//        return cell
//    }
//}
//
//*/
