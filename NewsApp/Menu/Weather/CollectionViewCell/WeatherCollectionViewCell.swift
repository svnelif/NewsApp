////
////  WeatherCollectionViewCell.swift
////  NewsApp
////
////  Created by Elif Ataseven  on 19.08.2024.
////
//
//import UIKit
//
//class WeatherCollectionViewCell: UICollectionViewCell {
//    static let identifier = "WeatherCollectionViewCell"
//    
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var temperatureLabel: UILabel!
//    @IBOutlet weak var iconImageView: UIImageView!
//
//    func configure(with model: HourlyUnits) {
//        // Zaman etiketini ayarla
//        timeLabel.text = model.time
//        
//        // Sıcaklık etiketini ayarla
//        temperatureLabel.text = "\(model.temperature2m)°"
//    }
//}
