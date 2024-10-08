import SafariServices
import SideMenu
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MenuListControllerDelegate {

    // Create a tableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    private let searchVC = UISearchController(searchResultsController: nil)
    private let settingsController = SettingsViewController()
    
    private var viewModels = [NewsTableViewCellViewModel]()
    private var articles = [Article]()
    private var currentPage = 0
    private let pageSize = 20
    private var isFetchingData = false
    private var hasMoreData = true
    private var searchText: String? // Arama terimi

    var menu: SideMenuNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News".localized
        searchVC.searchBar.placeholder = "Search".localized
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupMenu()
        
        fetchTopStories()
        createSearchBar()
        
    }

    private func fetchTopStories() {
        guard !isFetchingData, hasMoreData else { return }
        
        isFetchingData = true
        APICaller.shared.getTopStories(page: currentPage, pageSize: pageSize) { [weak self] result in
            self?.isFetchingData = false
            switch result {
            case .success(let articles):
                self?.articles.append(contentsOf: articles)
                let newViewModels = articles.compactMap { article in
                    NewsTableViewCellViewModel(
                        title: article.name,
                        subtitle: article.description,
                        imageURL: URL(string: article.image)
                    )
                }
                self?.viewModels.append(contentsOf: newViewModels)
                self?.currentPage += 1
                self?.hasMoreData = !articles.isEmpty
                
                // Arama terimini kontrol et ve sonuçları güncelle
                if let searchText = self?.searchText, !searchText.isEmpty {
                    self?.updateSearchResults(for: searchText)
                } else {
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath
        ) as? NewsTableViewCell else {
            fatalError("Failed to dequeue NewsTableViewCell")
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        guard let urlString = article.url, let url = URL(string: urlString) else {
            print("Invalid URL: \(article.url)")
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
        updateSearchResults(for: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchText = nil
        updateSearchResults(for: nil)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        updateSearchResults(for: searchText)
    }

    private func updateSearchResults(for searchText: String?) {
        guard let searchText = searchText, !searchText.isEmpty else {
            // Reset viewModels to show all articles if search text is empty
            viewModels = articles.compactMap { article in
                NewsTableViewCellViewModel(
                    title: article.name,
                    subtitle: article.description,
                    imageURL: URL(string: article.image)
                )
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        let filteredArticles = articles.filter { article in
            return article.name.lowercased().contains(searchText.lowercased()) ||
                   article.description.lowercased().contains(searchText.lowercased())
        }
        
        viewModels = filteredArticles.compactMap { article in
            NewsTableViewCellViewModel(
                title: article.name,
                subtitle: article.description,
                imageURL: URL(string: article.image)
            )
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * 2 {
            if !isFetchingData && hasMoreData {
                fetchTopStories()
            }
        }
    }
    
    //Menu
    @IBAction func didNews(_ sender: Any) {
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
