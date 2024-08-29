import UIKit

class CurrencyTableViewCell: UITableViewCell {

    let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.systemGray6 // Daha açık bir arka plan rengi
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowRadius = 4
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(currencyLabel)
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10), // Üstten boşluk bırakıyoruz
            currencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            currencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            currencyLabel.heightAnchor.constraint(equalToConstant: 50),
            currencyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10) // Alttan da boşluk ekliyoruz
        ])
    }
}
