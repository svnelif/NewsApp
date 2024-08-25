import UIKit
import SideMenu

class SettingsViewController: UIViewController, MenuListControllerDelegate {

    var menu: SideMenuNavigationController?
    
    private let chooseLanguageLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Language".localized
        label.font = .boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let englishLabel: UILabel = {
        let label = UILabel()
        label.text = "English".localized
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let englishSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(toggleLanguage), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let turkishLabel: UILabel = {
        let label = UILabel()
        label.text = "Turkish".localized
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let turkishSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(toggleLanguage), for: .valueChanged)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupSwitches()
        setupMenu()
    }
    
    private func setupViews() {
        view.addSubview(chooseLanguageLabel)
        view.addSubview(englishLabel)
        view.addSubview(englishSwitch)
        view.addSubview(turkishLabel)
        view.addSubview(turkishSwitch)
        
        NSLayoutConstraint.activate([
            chooseLanguageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            chooseLanguageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            englishLabel.topAnchor.constraint(equalTo: chooseLanguageLabel.bottomAnchor, constant: 20),
            englishLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            englishSwitch.centerYAnchor.constraint(equalTo: englishLabel.centerYAnchor),
            englishSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            turkishLabel.topAnchor.constraint(equalTo: englishLabel.bottomAnchor, constant: 20),
            turkishLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            turkishSwitch.centerYAnchor.constraint(equalTo: turkishLabel.centerYAnchor),
            turkishSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSwitches() {
        let appLanguage = LocalizationManager.shared.getCurrentLanguage()
        englishSwitch.isOn = (appLanguage == "en")
        turkishSwitch.isOn = (appLanguage == "tr")
    }
    
    @objc private func toggleLanguage(_ sender: UISwitch) {
        if sender == englishSwitch && sender.isOn {
            turkishSwitch.setOn(false, animated: true)
            changeLanguage(to: "en")
        } else if sender == turkishSwitch && sender.isOn {
            englishSwitch.setOn(false, animated: true)
            changeLanguage(to: "tr")
        }
        
        // Dil değişikliğini `WeatherViewController`'a gönder
        if let weatherVC = navigationController?.viewControllers.first(where: { $0 is WeatherViewController }) as? WeatherViewController {
            weatherVC.updateForSelectedLanguage()
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func changeLanguage(to language: String) {
        LocalizationManager.shared.setLanguage(languageCode: language)
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        updateLanguage()
    }
    
    private func updateLanguage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = initialViewController
            window.makeKeyAndVisible()
        }
    }
    
    @IBAction func didSettings(_ sender: Any) {
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
        var menuItem = MenuListController(with: SideMenuItem.allCases)
        menu = SideMenuNavigationController(rootViewController: menuItem)
        
        menuItem.delegate = self
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: true)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
}
