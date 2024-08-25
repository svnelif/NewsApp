import UIKit
import SideMenu

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MenuListControllerDelegate {

    private let tableView = UITableView()
    private var weatherData: [WeatherViewModel] = []
    var menu: SideMenuNavigationController?

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter city or district name".localized
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
        
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter city name.".localized
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Weather".localized
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(placeholderLabel)
        
        searchBar.delegate = self
        setupMenu()
        setupConstraints()
        setupTableView()
        
        // Dil değişikliği bildirimi için gözlemci ekle
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: NSNotification.Name("LanguageChanged"), object: nil)
            
        // Başlangıçta belirli bir şehir için hava durumu verilerini al
        fetchWeather(for: "Ankara")
    }

    @objc private func languageChanged() {
        // Dil değiştiğinde başlığı, placeholder metnini ve tabloyu güncelle
        self.title = "Weather".localized
        searchBar.placeholder = "Enter city or district name".localized
        placeholderLabel.text = "Please enter city name.".localized
        tableView.reloadData()
    }

    private func setupConstraints() {
        // Şehir arama çubuğunun kısıtlamaları
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Tablo görünümünün kısıtlamaları
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Placeholder etiketinin kısıtlamaları
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherTableViewCell")
    }

    private func fetchWeather(for cityName: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&units=metric&appid=62836853957d7ca33cd5bb5d8436b269"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Data fetch error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Gelen JSON verisini yazdırarak kontrol edin
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
                // Kullanıcının dil tercihine göre 'language' değişkenini ayarla
                let language = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"

                let model = WeatherViewModel(
                    date: self.convertUnixToDate(unixTime: weatherResponse.dt, language: language),
                    temperature: "\(Int(weatherResponse.main.temp))°C",
                    weatherDescription: (weatherResponse.weather.first?.description.capitalized ?? "N/A").localized,
                    humidity: weatherResponse.main.humidity,
                    windSpeed: weatherResponse.wind.speed,
                    iconName: weatherResponse.weather.first?.icon ?? "01d",
                    cityName: weatherResponse.name
                )
                self.weatherData = [model] // Arama sonuçlarını güncelle
                DispatchQueue.main.async {
                    self.tableView.reloadData() // Tabloyu yenile
                    self.placeholderLabel.isHidden = !self.weatherData.isEmpty
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    func convertUnixToDate(unixTime: Int, language: String? = nil) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let dateFormatter = DateFormatter()
        
        // Seçilen dili al
        let selectedLanguage = language ?? UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        
        switch selectedLanguage.lowercased() {
        case "tr":
            dateFormatter.locale = Locale(identifier: "tr")
        default:
            dateFormatter.locale = Locale(identifier: "en")
        }

        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: date)
    }

    func updateForSelectedLanguage() {
        self.title = "Weather".localized
        searchBar.placeholder = "Enter city or district name".localized
        placeholderLabel.text = "Please enter city name.".localized
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as? WeatherTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: weatherData[indexPath.row])
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let cityName = searchBar.text, !cityName.isEmpty else { return }
        searchBar.resignFirstResponder() // Klavyeyi kapatır
        fetchWeather(for: cityName)
    }
    
    //Menu
    @IBAction func didWeather(_ sender: Any) {
        present(menu!, animated: true)
    }
    
    
    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
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

    private func setupMenu() {
        let menuItem = MenuListController(with: SideMenuItem.allCases)
        menu = SideMenuNavigationController(rootViewController: menuItem)
        
        menuItem.delegate = self
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: true)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
}
