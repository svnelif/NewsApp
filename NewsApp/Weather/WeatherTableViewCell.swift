import UIKit

class WeatherTableViewCell: UITableViewCell {

    // MARK: - UI Elements
    
    private let cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()

    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .blue
        label.numberOfLines = 1
        return label
    }()

    private let windSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .orange
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(weatherIconImageView)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(humidityLabel)
        contentView.addSubview(windSpeedLabel)
        contentView.addSubview(cityNameLabel)
        
        // Layout constraints
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        humidityLabel.translatesAutoresizingMaskIntoConstraints = false
        windSpeedLabel.translatesAutoresizingMaskIntoConstraints = false
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cityNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cityNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cityNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            weatherIconImageView.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 16),
            weatherIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 100),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            temperatureLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 16),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            humidityLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            humidityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            windSpeedLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            windSpeedLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 8),
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),  // Center horizontally
                      
        ])
    }

    func configure(with model: WeatherViewModel) {
        cityNameLabel.text = model.cityName
        dateLabel.text = model.date
        temperatureLabel.text = model.temperature
        descriptionLabel.text = model.weatherDescription
        humidityLabel.text = "Humidity".localized + ": \(model.humidity)%"
        windSpeedLabel.text = "Wind: \(model.windSpeed) m/s".localized
        weatherIconImageView.image = UIImage(named: model.iconName)
    }


}
