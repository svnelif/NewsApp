import UIKit
import SideMenu

class MenuViewController: UIViewController, MenuListControllerDelegate {

    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Menu Page"
        
        setupMenu()
        tabBarController?.tabBar.items?[0].title = "Home Page".localized
        tabBarController?.tabBar.items?[1].title = "Settings".localized
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
        var menuItem = MenuListController(with: SideMenuItem.allCases)
        menu = SideMenuNavigationController(rootViewController: menuItem)
        
        menuItem.delegate = self
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: true)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
}
