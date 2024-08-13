import UIKit
import SideMenu

class CurrencyViewController: UIViewController, MenuListControllerDelegate {
 
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var tryLabel: UILabel!
    @IBOutlet weak var cadLabel: UILabel!
    @IBOutlet weak var chfLabel: UILabel!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var jpyLabel: UILabel!
    @IBOutlet weak var getRatesButton: UIButton!
    
    @IBOutlet weak var labell: UILabel!
    
    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Currency".localized
        
        setupUI()
        setupMenu()
        
    }
    func setupUI() {
        // Background Color
        view.backgroundColor = .white
        
        // Customize Labels
        let labels = [usdLabel, tryLabel, cadLabel, chfLabel, gbpLabel, jpyLabel]
        
        for label in labels {
            label?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            label?.textColor = UIColor.black
            label?.layer.cornerRadius = 8
            label?.layer.masksToBounds = true
            label?.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2) // Blue background
            label?.textAlignment = .center
            label?.layer.shadowColor = UIColor.black.cgColor
            label?.layer.shadowOffset = CGSize(width: 0, height: 2)
            label?.layer.shadowOpacity = 0.3
            label?.layer.shadowRadius = 10
        }
        
        // Stack Views Setup
        let currencyStack = UIStackView(arrangedSubviews: labels.compactMap { $0 })
        currencyStack.axis = .vertical
        currencyStack.alignment = .fill
        currencyStack.distribution = .equalSpacing
        currencyStack.spacing = 15
        currencyStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currencyStack)
        
        // Button Styling
        getRatesButton.setTitle("Get Rates".localized, for: .normal)
        getRatesButton.backgroundColor = UIColor.systemBlue
        getRatesButton.setTitleColor(UIColor.white, for: .normal)
        getRatesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        getRatesButton.layer.cornerRadius = 12
        getRatesButton.layer.shadowColor = UIColor.black.cgColor
        getRatesButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        getRatesButton.layer.shadowOpacity = 0.4
        getRatesButton.layer.shadowRadius = 6
        
        labell.text = "For one euro currency.".localized
        labell.textAlignment = .center
        // Add button to the view hierarchy
        view.addSubview(getRatesButton)
        getRatesButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for Stack View and Button
        NSLayoutConstraint.activate([
            currencyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currencyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            currencyStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40), // Increased leading constraint
            currencyStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40), // Increased trailing constraint
            
            getRatesButton.topAnchor.constraint(equalTo: currencyStack.bottomAnchor, constant: 30),
            getRatesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getRatesButton.widthAnchor.constraint(equalToConstant: 200),
            getRatesButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
    }
    
    //Weather
    func didSelectMenuItem(named: SideMenuItem) {
        menu?.dismiss(animated: true, completion: { [weak self] in
            //self?.title = named.rawValue
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
    
    @IBAction func didCurrency(_ sender: Any) {
        present(menu!, animated: true)
    }
    
    
    
    @IBAction func getRatesClicked(_ sender: Any) {
        // Request & Session
        // Response & Data
        // Parsing
        let url = URL(string: "http://data.fixer.io/api/latest?access_key=3972effb5ad7b9df6fc6d1bf4136ffa7&format=1")
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { data, response, error in
           //Hata mesajı varsa
            if error != nil {
                let alert = UIAlertController(title: "Error".localized, message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let okButton = UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            //Hata mesajı yoksa
            else{
                if data != nil {
                    //Json'dan veri almak için
                    do {
                        
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
                        
                        //ASYNC
                        DispatchQueue.main.async {
                            if let rates = jsonResponse["rates"] as? [String : Any] {
                                
                                //rates
                                if let usd = rates["USD"] as? Double {
                                    self.usdLabel.text = "USD: \(usd)"
                                }
                                if let turk = rates["TRY"] as? Double {
                                    self.tryLabel.text = "TRY: \(turk)"
                                }
                                if let cad = rates["CAD"] as? Double {
                                    self.cadLabel.text = "CAD: \(cad)"
                                }
                                if let chf = rates["CHF"] as? Double {
                                    self.chfLabel.text = "CHF: \(chf)"
                                }
                                if let gbp = rates["GBP"] as? Double {
                                    self.gbpLabel.text = "GBP: \(gbp)"
                                }
                                if let jpy = rates["JPY"] as? Double {
                                    self.jpyLabel.text = "JPY: \(jpy)"
                                }
                            }
                        }
                    } catch {
                        print("Error!".localized)
                    }
                }
            }
        }
        task.resume()
    }
}
