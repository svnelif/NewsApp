import UIKit

class PharmacyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currDate: UILabel!
    @IBOutlet weak var txtSehir: UITextField!
    @IBOutlet weak var btnGetir: UIButton!

    var nameArray = [String]()
    var distArray = [String]()
    var addressArray = [String]()
    var phoneArray = [String]()
    var locArray = [String]()
    var il: String = "Edirne"

    @IBAction func btnSearchButton(_ sender: Any) {
        guard let cityText = txtSehir.text, !cityText.isEmpty else {
            let alert = UIAlertController(title: "Uyarı!", message: "Lütfen bir şehir adı giriniz.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        
        il = cityText.lowercased().convertedToSlug()
        title = "\(il.capitalized) Nöbetçi Eczaneler"
        txtSehir.text = ""

        nameArray.removeAll()
        distArray.removeAll()
        addressArray.removeAll()
        phoneArray.removeAll()
        locArray.removeAll()
        tableView.reloadData()

        getJsonUrl()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        formatter.timeZone = TimeZone(abbreviation: "UTC+3")
        formatter.locale = Locale(identifier: "tr-TR")

        let utcTimeZoneStr = formatter.string(from: date)
        if let dateLabel = currDate {
            dateLabel.text = "\(utcTimeZoneStr) tarihi için nöbetçi eczaneler"
        } else {
            print("currDate UILabel'inin bağlantısı yapılmamış.")
        }
        self.title = "\(il.capitalized) Nöbetçi Eczaneler"

        if btnGetir == nil {
            btnGetir = UIButton(type: .system)
            btnGetir.frame = CGRect(x: 20, y: 200, width: 100, height: 40)
            btnGetir.setTitle("Getir", for: .normal)
            view.addSubview(btnGetir)
        }

        btnGetir.backgroundColor = .systemBlue
        btnGetir.layer.cornerRadius = 5
        btnGetir.tintColor = .white
        
        getJsonUrl()
    }

    func getJsonUrl() {
        let headers = [
            "content-type": "application/json",
            "authorization": "apikey 0NzFnjXImTVOzICi0lqYLj:6EyugUS3Pw5Eg4zZSpt7TQ"
        ]

        guard let url = URL(string: "https://api.collectapi.com/health/dutyPharmacy?il=\(il)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared

        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                   let eczaArray = jsonResponse["result"] as? [[String: Any]] {
                    for eczaDict in eczaArray {
                        if let name = eczaDict["name"] as? String {
                            self.nameArray.append(name)
                        }
                        if let dist = eczaDict["dist"] as? String {
                            self.distArray.append(dist)
                        }
                        if let address = eczaDict["address"] as? String {
                            self.addressArray.append(address)
                        }
                        if let phone = eczaDict["phone"] as? String {
                            self.phoneArray.append(phone)
                        }
                        if let loc = eczaDict["loc"] as? String {
                            self.locArray.append(loc)
                        }
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        dataTask.resume()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PharmacyTableViewCell else {
            fatalError("Unable to dequeue a cell with identifier 'cell'")
        }

        cell.lblName.text = nameArray[indexPath.row].uppercased()
        
        if !cell.lblName.text!.hasSuffix("Sİ") && !cell.lblName.text!.hasSuffix("SI") {
            cell.lblName.text!.append(" ECZANESİ")
        }

        cell.lblDist.text = "・" + distArray[indexPath.row].capitalized
        cell.lblAddress.text = addressArray[indexPath.row].capitalized

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            print("Unable to instantiate DetailViewController")
            return
        }

        detailVC.nameString = nameArray[indexPath.row]
        detailVC.distString = distArray[indexPath.row]
        detailVC.addressString = addressArray[indexPath.row]
        detailVC.phoneString = phoneArray[indexPath.row]
        detailVC.locString = locArray[indexPath.row]

        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true, completion: nil)
    }
}

extension String {
    func convertedToSlug() -> String {
        var slug = self.lowercased()
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789-")
        slug = slug.unicodeScalars.filter { allowedCharacters.contains($0) }
                                   .map(String.init)
                                   .joined()
        slug = slug.replacingOccurrences(of: " ", with: "-")
        return slug
    }
}
