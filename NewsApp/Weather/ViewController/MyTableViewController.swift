//
//  MyTableViewController.swift
//

import UIKit

class MyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presidents.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return "Period 1961-2021"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCellIdetifier", for: indexPath)
        
        guard presidents.count > indexPath.row else {
            print("You have a problem")
            return cell
        }
        
        cell.textLabel?.text = presidents[indexPath.row][.name]
        cell.detailTextLabel?.text = presidents[indexPath.row][.years]
    
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let detailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else {
            return
        }
        
        detailsViewController.loadViewIfNeeded()
        
        detailsViewController.presidentNameLabel.text = self.tableView.cellForRow(at: indexPath)?.textLabel?.text ?? ""
        self.navigationController?.pushViewController(detailsViewController, animated: true)
        
//        self.performSegue(withIdentifier: "showPresidentDetailsSegue", sender: self.tableView.cellForRow(at: indexPath))
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let segueIdentifier = segue.identifier else {
//            return
//        }
//
//
//
//        switch segueIdentifier {
//        case "showPresidentDetailsSegue":
//            guard let destinationController = segue.destination as? DetailsViewController else {
//                return
//            }
//
//            guard let selectedCell = sender as? UITableViewCell else {
//                return
//            }
//            destinationController.presidentName = selectedCell.textLabel?.text ?? ""
//        default:
//            return
//        }
//    }

}
