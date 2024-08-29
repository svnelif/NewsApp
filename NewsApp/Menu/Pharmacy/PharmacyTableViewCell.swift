import UIKit

class PharmacyTableViewCell: UITableViewCell {

    let lblName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let lblDist: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let lblAddress: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lblName)
        contentView.addSubview(lblDist)
        contentView.addSubview(lblAddress)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            lblName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            lblName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            lblName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            lblDist.topAnchor.constraint(equalTo: lblName.bottomAnchor, constant: 5),
            lblDist.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            lblDist.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            lblAddress.topAnchor.constraint(equalTo: lblDist.bottomAnchor, constant: 5),
            lblAddress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            lblAddress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            lblAddress.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
