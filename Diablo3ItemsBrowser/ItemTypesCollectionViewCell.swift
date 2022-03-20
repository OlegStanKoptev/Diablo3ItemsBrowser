//
//  ItemTypesCollectionViewCell.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit

class ItemTypesCollectionViewCell: UICollectionViewCell {
    static let identifier = "myCell"

    var textLabel = UILabel()
    var detailTextLabel = UILabel()
    var currentIndex: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        layer.cornerRadius = 12
        unhighlight()

        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.font = .preferredFont(forTextStyle: .body)
        textLabel.adjustsFontForContentSizeCategory = true

        detailTextLabel.textAlignment = .center
        detailTextLabel.numberOfLines = 3
        detailTextLabel.textColor = .secondaryLabel
        detailTextLabel.font = .preferredFont(forTextStyle: .footnote)
        detailTextLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(textLabel)
        stack.addArrangedSubview(detailTextLabel)

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func updateCellContent(with itemType: ItemType, highlighted: Bool = false) {
        textLabel.text = itemType.name ?? "no name"
        let id = itemType.id ?? "no id"
        if itemType.itemsCount != 0 {
            detailTextLabel.text = "\(itemType.itemsCount) of \(id)"
        } else {
            detailTextLabel.text = id
        }
//        detailTextLabel.text = itemType.id ?? "no id"
        if highlighted { highlight() } else { unhighlight() }
    }

    func highlight() {
        backgroundColor = .systemFill
    }

    func unhighlight() {
        backgroundColor = UIColor(named: "ItemBackgroundColor")
    }
}
