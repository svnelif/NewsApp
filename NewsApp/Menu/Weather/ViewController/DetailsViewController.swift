//
//  DetailsViewController.swift
//

import UIKit

class DetailsViewController: UIViewController {

    var presidentName: String = ""
    
    @IBOutlet weak var presidentNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .newDataAvailable, object: nil, queue: OperationQueue.main) {[weak self] _ in

                self?.reloadDataOnScreen()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presidentNameLabel.text = "Temp: Loading"
//        self.presidentNameLabel.text = presidentName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RequestManager.fetchData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadDataOnScreen() {
        self.presidentNameLabel.text = "Temp: \(RequestManager.temperature)"
    }

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

