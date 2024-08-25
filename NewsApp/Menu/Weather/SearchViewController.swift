import UIKit

class SearchViewContr: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var weatherData: [WeatherViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherTableViewCell.self, forCellReuseIdentifier: "WeatherTableViewCell")

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else { return }
        fetchWeatherData(for: city)
        searchBar.resignFirstResponder()
    }

    private func fetchWeatherData(for city: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&units=metric&appid=YOUR_API_KEY"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Data fetch error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let model = WeatherViewModel(
                    date: self.convertUnixToDate(unixTime: weatherResponse.dt),
                    temperature: "\(Int(weatherResponse.main.temp))°C",
                    weatherDescription: weatherResponse.weather.first?.description.capitalized ?? "N/A",
                    humidity: weatherResponse.main.humidity,
                    windSpeed: weatherResponse.wind.speed,
                    iconName: weatherResponse.weather.first?.icon ?? "01d", cityName: ""
                )
                self.weatherData = [model]

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    private func convertUnixToDate(unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: date)
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
}
