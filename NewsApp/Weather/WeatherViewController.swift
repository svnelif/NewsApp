import UIKit
import SideMenu

class WeatherViewController: UIViewController, MenuListControllerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table = UITableView!
    
    var models = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        table.delegate = self
        table.dataSource = self
    }
    
    //Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}

struct Weather {
    
    
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
