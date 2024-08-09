import SafariServices
import SideMenu
import UIKit

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MenuListControllerDelegate {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let settingsController = SettingsViewController()
    
    private var weatherData = [String]() // Example data array
    var menu: SideMenuNavigationController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather".localized
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        setupMenu()
        
        // Dil değişikliği bildirimlerini dinle
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .languageChanged, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = weatherData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle cell selection
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
        // Dil değişikliğini UI'ye yansıt
        title = "Weather".localized
        // Örneğin, veri ve UI öğelerini güncelleyin
        tableView.reloadData()
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
