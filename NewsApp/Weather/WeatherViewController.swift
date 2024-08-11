import UIKit
import CoreLocation
import SafariServices
import SideMenu

class WeatherViewController: UIViewController, MenuListControllerDelegate, CLLocationManagerDelegate {
    static let identifier = "WeatherViewController"
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var dailyTableView: UITableView!

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let settingsController = SettingsViewController()
    
    var location: Location!
    var index = 0
    var viewModel: WeatherViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            viewModel.location.observe { [unowned self] in
                if let cityName = $0.name {
                    self.cityLabel.text = cityName
                }
            }
            viewModel.currentWeather.observe { [unowned self] in
                self.conditionLabel.text = $0.condition
                self.temperatureLabel.text = $0.temperatureText
                self.dayOfWeekLabel.text = $0.dateText
            }
            viewModel.hourlyWeatherItems.observe { [unowned self] list in
                self.hourlyCollectionView.reloadData()
            }
            viewModel.dailyWeatherItems.observe { [unowned self] list in
                self.dailyTableView.reloadData()
            }
            viewModel.detailWeather.observe { [unowned self] list in
                self.dailyTableView.reloadData()
            }
            viewModel.temperatureUnit.observe { [unowned self] unit in
                self.temperatureLabel.text = viewModel.currentWeather.value?.temperatureText
                self.dailyTableView.reloadData()
                self.hourlyCollectionView.reloadData()
            }
        }
    }
    var menu: SideMenuNavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load at index \(self.index)")
        view.backgroundColor = .systemRed
        view.addSubview(tableView)
        setupMenu()
        
        // Dil değişikliği bildirimlerini dinle
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .languageChanged, object: nil)
        
        registerDailyTableViewCells()
        self.hourlyCollectionView.dataSource = self
        self.dailyTableView.dataSource = self
        self.dailyTableView.delegate = self
        self.dailyTableView.separatorStyle = .none
        if let cityName = location?.name {
            self.cityLabel.text = cityName
        }
        getWeatherData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let temperatureUnit = TemperatureUnit.shared.unit
        if viewModel?.temperatureUnit.value != temperatureUnit {
            viewModel?.temperatureUnit.value = temperatureUnit
        }
        print("view will appear as index \(self.index)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    @IBAction func didWeather(_ sender: Any) {
        present(menu!, animated: true)
    }

    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
            var viewController: UIViewController?
            switch named {
            case .language:
                let settingsVC = SettingsViewController()
                let navigationController = UINavigationController(rootViewController: settingsVC)
                settingsVC.title = "Settings".localized
                self?.present(navigationController, animated: true, completion: nil)
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

    @objc private func handleLanguageChange() {
        title = "Weather".localized
        tableView.reloadData()
    }
    
    private func setEmptyStringToLabels() {
        let emptyString = ""
        self.cityLabel.text = emptyString
        self.conditionLabel.text = emptyString
        self.temperatureLabel.text = emptyString
    }
    
    private func registerDailyTableViewCells() {
        let dailyTableViewCellNib = UINib(nibName: DailyTableViewCell.identifier, bundle: nil)
        dailyTableView.register(dailyTableViewCellNib, forCellReuseIdentifier: DailyTableViewCell.identifier)
        let detailTableViewCell = UINib(nibName: DetailTableViewCell.identifier, bundle: nil)
        dailyTableView.register(detailTableViewCell, forCellReuseIdentifier: DetailTableViewCell.identifier)
    }
    
    private func getWeatherData() {
        print("get weather")
        guard let location = self.location else {
            print(LocationError.noLocationConfigured.localizedDescription)
            return
        }
        self.viewModel = WeatherViewModel(location: location)
        self.viewModel?.retrieveWeatherData()
    }
}

extension WeatherViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.hourlyWeatherItems.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCollectionViewCell.identifier, for: indexPath) as? HourlyCollectionViewCell else {
            return HourlyCollectionViewCell()
        }
        guard let weatherItem = viewModel?.hourlyWeatherItems.value?[indexPath.row] else {
            return HourlyCollectionViewCell()
        }
        cell.setWeatherData(from: weatherItem)
        return cell
    }
}

extension WeatherViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DailyTableViewSection.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = DailyTableViewSection(sectionIndex: section) else {
            return 0
        }
        switch section {
        case .daily:
            return viewModel?.dailyWeatherItems.value?.count ?? 0
        case .detail:
            return viewModel?.detailWeather.value?.totalRow ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = DailyTableViewSection(sectionIndex: indexPath.section) else {
            return DailyTableViewCell()
        }
        switch section {
        case .daily:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyTableViewCell.identifier, for: indexPath) as? DailyTableViewCell,
                let weatherItem = viewModel?.dailyWeatherItems.value?[indexPath.row] else {
                return DailyTableViewCell()
            }
            cell.setWeatherData(from: weatherItem)
            return cell
        case .detail:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.identifier, for: indexPath) as? DetailTableViewCell,
                let weatherPair = viewModel?.detailWeather.value?.getDetailWeather(at: indexPath.row) else {
                return DetailTableViewCell()
            }
            cell.setWeatherData(using: weatherPair)
            return cell
        }
    }
}

extension WeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = DailyTableViewSection(sectionIndex: indexPath.section) else {
            return DailyTableViewSection.defaultCellHeight
        }
        return section.cellHeight
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}








/*
import SafariServices
import SideMenu
import UIKit
import CoreLocation

class WeatherViewController: UIViewController, MenuListControllerDelegate, CLLocationManagerDelegate {

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let settingsController = SettingsViewController()
    
    var menu: SideMenuNavigationController?


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather".localized
        view.backgroundColor = .systemRed
        view.addSubview(tableView)
        
        setupMenu()
        
        
        // Dil değişikliği bildirimlerini dinle
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .languageChanged, object: nil)
        
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    @IBAction func didWeather(_ sender: Any) {
        present(menu!, animated: true)
    }

    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
            var viewController: UIViewController?
            switch named {
            case .language:
                let settingsVC = SettingsViewController()
                let navigationController = UINavigationController(rootViewController: settingsVC)
                settingsVC.title = "Settings".localized
                self?.present(navigationController, animated: true, completion: nil)
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

    @objc private func handleLanguageChange() {
        title = "Weather".localized
        tableView.reloadData()
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
*/
