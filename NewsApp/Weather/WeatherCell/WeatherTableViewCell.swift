//import UIKit
//
//class WeatherTableViewCell: UITableViewCell {
//
//    static let identifier = "WeatherTableViewCell"
//
//    private let timeLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        return label
//    }()
//
//    private let temperatureLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
//        return label
//    }()
//
//    private let iconImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(timeLabel)
//        contentView.addSubview(temperatureLabel)
//        contentView.addSubview(iconImageView)
//
//        contentView.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
//        contentView.layer.cornerRadius = 8
//        contentView.layer.masksToBounds = true
//
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        let imageSize: CGFloat = contentView.frame.size.height - 20
//        iconImageView.frame = CGRect(x: 10, y: 10, width: imageSize, height: imageSize)
//
//        timeLabel.frame = CGRect(x: iconImageView.frame.maxX + 10, y: 10, width: contentView.frame.size.width/2, height: contentView.frame.size.height/2)
//        temperatureLabel.frame = CGRect(x: iconImageView.frame.maxX + 10, y: contentView.frame.size.height/2, width: contentView.frame.size.width/2, height: contentView.frame.size.height/2)
//    }
//
//    // Hücreyi verilerle yapılandırmak için kullanılan fonksiyon
//    func configure(with temperature: Double, time: String, icon: UIImage? = nil) {
//        temperatureLabel.text = "\(temperature)°"
//        timeLabel.text = time
//        iconImageView.image = icon
//    }
//
//    static func nib() -> UINib {
//        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
//    }
//}
