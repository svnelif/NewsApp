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

