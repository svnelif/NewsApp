import UIKit
import SideMenu

class WeatherViewController: UIViewController, MenuListControllerDelegate {

    private let settingsController = SettingsViewController()
    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        setupMenu()
        
    }
    
    private func setupMenu() {
        
        var menuItem = MenuListController(with: SideMenuItem.allCases)
        menu = SideMenuNavigationController(rootViewController: menuItem)
        
        menuItem.delegate = self
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: true)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
        addChildControllers()
    }
    
  private func addChildControllers() {
      addChild(settingsController)
      view.addSubview(settingsController.view)
      settingsController.view.frame = view.bounds
      settingsController.didMove(toParent: self)
      settingsController.view.isHidden = true
  }
 
    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
            var viewController = UIViewController()
            self?.title = named.rawValue
            switch named {
            case .settings:
                viewController = SettingsViewController()
            }
            
            
        })
    }

        @IBAction func didWeather(_ sender: Any) {
            present(menu!, animated: true)
        }
        
    
}
