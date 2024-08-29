import UIKit
import SideMenu

class MenuViewController: UIViewController, MenuListControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var menu: SideMenuNavigationController?
    @IBOutlet weak var tableView: UITableView!
    
    var menuItems = ["News",
                     "Weather",
                     "Pharmacy on Duty",
                     "Currency"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home Page".localized
        
        // Cell kaydını yapıyoruz
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuItemCell")
            
        tableView.delegate = self
        tableView.dataSource = self
        
        setupMenu()
        tabBarController?.tabBar.items?[0].title = "Home Page".localized
        tabBarController?.tabBar.items?[1].title = "Settings".localized
    }

    // TableView Delegate & DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row].localized
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = menuItems[indexPath.row]
        
        var viewController: UIViewController?
        switch selectedItem {
        case "News":
            viewController = ViewController()
        case "Weather":
            viewController = WeatherViewController()
        case "Pharmacy on Duty":
            viewController = PharmacyViewController()
        case "Currency":
            viewController = CurrencyViewController()
        default:
            break
        }
        
        if let vc = viewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    //Menu
    @IBAction func didMenu(_ sender: Any) {
        present(menu!, animated: true)
    }
    
    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
            var viewController: UIViewController?
            switch named {
            case .language:
                viewController = LanguageViewController()
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
