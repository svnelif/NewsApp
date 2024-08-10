import SafariServices
import SideMenu
import UIKit

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MenuListControllerDelegate, UISearchBarDelegate {
    
    private let backgroundImageView = UIImageView()
    private let darkOverlayView = UIView()
    private let mainStackView = UIStackView()
    private let statusImageView = UIImageView()
    private let temperatureLabel = UILabel()
    private let cityLabel = UILabel()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let searchVC = UISearchController(searchResultsController: nil)
    private let settingsController = SettingsViewController()
    
    private var weatherData = [String]()
    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather".localized
        view.backgroundColor = .systemBackground
        
        setupSearchBar()
        style()
        layout()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setupMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .languageChanged, object: nil)
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
        searchVC.obscuresBackgroundDuringPresentation = false
        searchVC.searchBar.placeholder = "Enter city name"
        searchVC.searchBar.sizeToFit()
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
        title = "Weather".localized
        tableView.reloadData()
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

extension WeatherViewController {
    private func style() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "weatherBackground") // Ensure this name matches your asset
        
        darkOverlayView.translatesAutoresizingMaskIntoConstraints = false
        darkOverlayView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.spacing = 16
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.image = UIImage(systemName: "sun.max.fill")
        statusImageView.tintColor = .yellow
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        temperatureLabel.attributedText = attributedText(with: "15")
        temperatureLabel.textColor = .white
        temperatureLabel.layer.shadowColor = UIColor.black.cgColor
        temperatureLabel.layer.shadowRadius = 4.0
        temperatureLabel.layer.shadowOpacity = 0.7
        temperatureLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        temperatureLabel.layer.masksToBounds = false
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        cityLabel.text = "Ankara"
        cityLabel.textColor = .white
        cityLabel.layer.shadowColor = UIColor.black.cgColor
        cityLabel.layer.shadowRadius = 4.0
        cityLabel.layer.shadowOpacity = 0.7
        cityLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        cityLabel.layer.masksToBounds = false
        
        // Fallback view for when the background image is not present
        view.backgroundColor = .systemBlue
    }
    
    private func layout() {
        view.addSubview(backgroundImageView)
        view.addSubview(darkOverlayView)
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(statusImageView)
        mainStackView.addArrangedSubview(temperatureLabel)
        mainStackView.addArrangedSubview(cityLabel)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            darkOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            darkOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            darkOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            darkOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusImageView.heightAnchor.constraint(equalToConstant: 85),
            statusImageView.widthAnchor.constraint(equalToConstant: 85)
        ])
    }
    
    private func attributedText(with text: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 100),
            .shadow: NSShadow()
        ])
        attributedText.append(NSAttributedString(string: "°C", attributes: [
            .font: UIFont.systemFont(ofSize: 60),
            .foregroundColor: UIColor.white,
            .shadow: NSShadow()
        ]))
        return attributedText
    }
}

/*
 
 extension WeatherViewController {
     private func style() {
         backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
         backgroundImageView.contentMode = .scaleAspectFill
         
         locationButton.translatesAutoresizingMaskIntoConstraints = false
         locationButton.setImage(UIImage(named: "location.circle.fill"), for: .normal)
         locationButton.tintColor = .label
         locationButton.layer.cornerRadius = 40 / 2
         locationButton.contentVerticalAlignment = .fill
         locationButton.contentHorizontalAlignment = .fill
         
         searchButton.translatesAutoresizingMaskIntoConstraints = false
         searchButton.setImage(UIImage(named: "magnifyingglass"), for: .normal)
         searchButton.tintColor = .label
         searchButton.layer.cornerRadius = 40 / 2
         searchButton.contentVerticalAlignment = .fill
         searchButton.contentHorizontalAlignment = .fill
         
         searchTextField.translatesAutoresizingMaskIntoConstraints = false
         searchTextField.placeholder = "Search"
         searchTextField.font = UIFont.preferredFont(forTextStyle: .title1)
         searchTextField.borderStyle = .roundedRect
         searchTextField.textAlignment = .right
         searchTextField.backgroundColor = .systemFill
         
         searchStackView.translatesAutoresizingMaskIntoConstraints = false
         searchStackView.spacing = 8
         searchStackView.axis = .horizontal
         
         mainStackView.translatesAutoresizingMaskIntoConstraints = false
         mainStackView.spacing = 10
         mainStackView.axis = .vertical
         mainStackView.alignment = .trailing
         
         statusImageView.translatesAutoresizingMaskIntoConstraints = false
         statusImageView.image = UIImage(named: "sun.max")
         statusImageView.tintColor = .label
         
         temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
         temperatureLabel.font = UIFont.systemFont(ofSize: 80)
         temperatureLabel.attributedText = attributedText(with: "15")
         
         cityLabel.translatesAutoresizingMaskIntoConstraints = false
         cityLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
         cityLabel.text = "Ankara"
     }
     
     private func layout() {
         view.addSubview(backgroundImageView)
         view.addSubview(mainStackView)
         mainStackView.addArrangedSubview(searchStackView)
         searchStackView.addArrangedSubview(locationButton)
         searchStackView.addArrangedSubview(searchTextField)
         searchStackView.addArrangedSubview(searchButton)
         mainStackView.addArrangedSubview(statusImageView)
         mainStackView.addArrangedSubview(temperatureLabel)
         mainStackView.addArrangedSubview(cityLabel)
         NSLayoutConstraint.activate([
             
             backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
             backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             view.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor),
             view.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
             
             mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
             mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
             view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: 8),
             
             searchStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
             locationButton.heightAnchor.constraint(equalToConstant: 40),
             locationButton.widthAnchor.constraint(equalToConstant: 40),
             
             searchButton.heightAnchor.constraint(equalToConstant: 40),
             searchButton.widthAnchor.constraint(equalToConstant: 40),
             
             statusImageView.heightAnchor.constraint(equalToConstant: 85),
             statusImageView.widthAnchor.constraint(equalToConstant: 85)
         ])
     }
     private func attributedText(with text: String) -> NSMutableAttributedString {
         
         let attributedText = NSMutableAttributedString(string: text, attributes: [.foregroundColor: UIColor.label, .font: UIFont.boldSystemFont(ofSize: 90)])
         attributedText.append(NSAttributedString(string: "°C", attributes: [.font: UIFont.systemFont(ofSize: 50)]))
         
         return attributedText
     }
 }


 */
