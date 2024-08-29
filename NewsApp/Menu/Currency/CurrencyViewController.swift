import UIKit
import SideMenu

class CurrencyViewController: UIViewController, MenuListControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    var tableView: UITableView!
    var getRatesButton: UIButton!
    var labell: UILabel!
    var menu: SideMenuNavigationController?
    var rates: [String: Double] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenu()
    }

    func setupUI() {
        view.backgroundColor = .white

        // Create Label
        labell = UILabel()
        labell.text = "For one euro currency.".localized
        labell.textAlignment = .center
        labell.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        labell.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labell)
        
        // Create Table View
        tableView = UITableView()
        tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: "CurrencyCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Create Button
        getRatesButton = UIButton()
        getRatesButton.setTitle("Get Rates".localized, for: .normal)
        getRatesButton.backgroundColor = UIColor.systemBlue
        getRatesButton.setTitleColor(UIColor.white, for: .normal)
        getRatesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        getRatesButton.layer.cornerRadius = 12
        getRatesButton.layer.shadowColor = UIColor.black.cgColor
        getRatesButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        getRatesButton.layer.shadowOpacity = 0.4
        getRatesButton.layer.shadowRadius = 6
        getRatesButton.translatesAutoresizingMaskIntoConstraints = false
        getRatesButton.addTarget(self, action: #selector(getRatesClicked(_:)), for: .touchUpInside)
        view.addSubview(getRatesButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            labell.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20), // Üstten boşluk bırakıyoruz
            labell.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labell.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: labell.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: getRatesButton.topAnchor, constant: -32),
            
            getRatesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getRatesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            getRatesButton.widthAnchor.constraint(equalToConstant: 200),
            getRatesButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
        let menuItem = MenuListController(with: SideMenuItem.allCases)
        menu = SideMenuNavigationController(rootViewController: menuItem)
        
        menuItem.delegate = self
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: true)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }

    @IBAction func didCurrency(_ sender: Any) {
        if let menu = menu {
            present(menu, animated: true)
        } else {
            print("Menu is nil")
        }
    }
    
    @objc func getRatesClicked(_ sender: Any) {
        guard let url = URL(string: "http://data.fixer.io/api/latest?access_key=3972effb5ad7b9df6fc6d1bf4136ffa7&format=1") else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                let alert = UIAlertController(title: "Error".localized, message: error.localizedDescription, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
                alert.addAction(okButton)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Parse JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
                   let rates = jsonResponse["rates"] as? [String: Any] {
                    // Convert rates to [String: Double]
                    var parsedRates: [String: Double] = [:]
                    
                    for (key, value) in rates {
                        if let rate = value as? Double {
                            parsedRates[key] = rate
                        } else if let rateString = value as? String, let rate = Double(rateString) {
                            parsedRates[key] = rate
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.rates = parsedRates
                        self.tableView.reloadData() // Reload table data with new rates
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6 // Number of currency labels
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath) as! CurrencyTableViewCell
        let currencies = ["USD", "TRY", "CAD", "CHF", "GBP", "JPY"]
        let currency = currencies[indexPath.row]
        let rate = rates[currency] ?? 0
        cell.currencyLabel.text = "\(currency): \(rate)"
        return cell
    }
}
