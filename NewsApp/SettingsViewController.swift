import UIKit
class SettingsViewController: UIViewController {

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
            LocalizationManager.shared.setLanguage(languageCode: "en")
        } else if sender == turkishSwitch && sender.isOn {
            englishSwitch.setOn(false, animated: true)
            LocalizationManager.shared.setLanguage(languageCode: "tr")
        }
        updateLanguage()
    }
    
    private func updateLanguage() {
        // Uygulamanın root view controller'ını değiştirerek UI'yi yeni dil ile güncelleyin
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateInitialViewController()
        
        // Doğru pencerenin güncellendiğinden emin olun
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = initialViewController
            window.makeKeyAndVisible()
        }
    }
}
