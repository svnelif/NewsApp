import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Arayüz bileşenleri
    private let lblName = UILabel()
    private let lblDist = UILabel()
    private let lblAddress = UILabel()
    private let lblPhone = UILabel()
    private let lblLoc = UILabel()
    private let mapView = MKMapView()
    
    private let locationManager = CLLocationManager()
    
    var nameString: String!
    var distString: String!
    var addressString: String!
    var phoneString: String!
    var locString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Arayüzü yapılandır
        setupUI()
        
        // Konum güncellemelerini yapılandır
        setupLocationManager()
        
        // Harita ve konum bilgilerini ayarla
        setupMapView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        lblName.translatesAutoresizingMaskIntoConstraints = false
        lblDist.translatesAutoresizingMaskIntoConstraints = false
        lblAddress.translatesAutoresizingMaskIntoConstraints = false
        lblPhone.translatesAutoresizingMaskIntoConstraints = false
        lblLoc.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        lblName.font = UIFont.boldSystemFont(ofSize: 20)
        lblName.textAlignment = .center
        
        lblDist.font = UIFont.systemFont(ofSize: 16)
        lblAddress.font = UIFont.systemFont(ofSize: 16)
        lblPhone.font = UIFont.systemFont(ofSize: 16)
        lblLoc.font = UIFont.systemFont(ofSize: 16)
        
        mapView.delegate = self
        
        view.addSubview(lblName)
        view.addSubview(lblDist)
        view.addSubview(lblAddress)
        view.addSubview(lblPhone)
        view.addSubview(lblLoc)
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            lblName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            lblName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            lblDist.topAnchor.constraint(equalTo: lblName.bottomAnchor, constant: 10),
            lblDist.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            lblAddress.topAnchor.constraint(equalTo: lblDist.bottomAnchor, constant: 10),
            lblAddress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            lblPhone.topAnchor.constraint(equalTo: lblAddress.bottomAnchor, constant: 10),
            lblPhone.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            lblLoc.topAnchor.constraint(equalTo: lblPhone.bottomAnchor, constant: 10),
            lblLoc.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mapView.topAnchor.constraint(equalTo: lblLoc.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        // Navigation Bar butonlarını ekle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Yol Tarifi Al", style: .plain, target: self, action: #selector(rightHandAction))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Geri", style: .plain, target: self, action: #selector(leftHandAction))
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMapView() {
        guard let locString = locString else { return }
        let base = locString.components(separatedBy: ",")
        guard let lat = Double(base[0]), let lon = Double(base[1]) else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = nameString.hasSuffix("Sİ") || nameString.hasSuffix("SI") ? nameString.capitalized : "\(nameString.capitalized) Eczanesi"
        annotation.subtitle = "+90\(phoneString!)"
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
    }
    
    @objc
    func rightHandAction() {
        guard let locString = locString else { return }
        let corr = locString.components(separatedBy: ",")
        guard let lat = Double(corr[0]), let lon = Double(corr[1]) else { return }
        let requestLocation = CLLocation(latitude: lat, longitude: lon)
        
        CLGeocoder().reverseGeocodeLocation(requestLocation) { [weak self] (placemarks, error) in
            if let placemark = placemarks?.first {
                let newPlacemark = MKPlacemark(placemark: placemark)
                let item = MKMapItem(placemark: newPlacemark)
                item.name = "\(self?.nameString?.capitalized ?? "") Eczanesi"
                
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                item.openInMaps(launchOptions: launchOptions)
            }
        }
    }
    
    @objc
    func leftHandAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI() {
        lblName.text = nameString.hasSuffix("Sİ") || nameString.hasSuffix("SI") ? nameString.capitalized : "\(nameString.capitalized) Eczanesi"
        lblDist.text = distString.capitalized
        lblAddress.text = addressString.capitalized
        lblPhone.text = "+90\(phoneString!)"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationID = "anno1"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            pinView?.canShowCallout = true
            
            let button = UIButton(type: .system)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
}
