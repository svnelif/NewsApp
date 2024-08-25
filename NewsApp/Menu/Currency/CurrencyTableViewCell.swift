import UIKit

class CurrencyTableViewCell: UITableViewCell {

    static let identifier = "CurrencyTableViewCell"
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(currencyLabel)
        contentView.addSubview(valueLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            currencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(with currency: String, value: Double) {
        currencyLabel.text = currency
        valueLabel.text = String(format: "%.2f", value)
    }
}
