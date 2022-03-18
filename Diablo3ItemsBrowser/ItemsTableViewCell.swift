//
//  ItemsTableViewCell.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 17.03.2022.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {
    var name: UILabel!
    var id: UILabel!
    var iconView: UIImageView!
    
    private var isLoading: Bool = false
    private var isPlannedToShimmer: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        name = UILabel()
        id = UILabel()
        iconView = UIImageView()
        
        name.font = .preferredFont(forTextStyle: .body)
        name.adjustsFontForContentSizeCategory = true
        
        id.font = .preferredFont(forTextStyle: .caption1)
        id.textColor = .secondaryLabel
        id.adjustsFontForContentSizeCategory = true
        
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 4
        
        
        name.translatesAutoresizingMaskIntoConstraints = false
        id.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(name)
        contentView.addSubview(id)
        contentView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            iconView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -6),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 42),
            
            name.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 8),
            name.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            name.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            id.leftAnchor.constraint(equalTo: name.leftAnchor),
            id.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 3),
            id.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            id.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCellContent(with item: Item) {
        name.text = item.name ?? "no name"
        id.text = item.id
    }
    
    func startLoadingAnimation() {
        guard !isLoading else { return }
        self.isPlannedToShimmer = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if self.isPlannedToShimmer {
                self.isPlannedToShimmer = false
                self.iconView.backgroundColor = .tertiarySystemFill
                self.iconView.startShimmeringAnimation()
            }
        }
        UIView.transition(with: iconView, duration: 0.1, options: .transitionCrossDissolve) {
            self.iconView.image = nil
        }
        isLoading = true
    }
    
    func stopLoadingAnimation() {
        guard isLoading else { return }
        self.isPlannedToShimmer = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.iconView.backgroundColor = nil
            self?.iconView.stopShimmeringAnimation()
        }
        isLoading = false
    }
    
    func stopLoadingAnimationAndSetContentImage(_ image: UIImage?) {
        UIView.transition(with: iconView, duration: 0.1, options: .transitionCrossDissolve) {
            self.stopLoadingAnimation()
            self.iconView.image = image
        }
    }
}

