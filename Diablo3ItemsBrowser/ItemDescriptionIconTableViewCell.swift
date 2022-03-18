//
//  ItemDescriptionIconTableViewCell.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 17.03.2022.
//

import UIKit

class ItemDescriptionIconTableViewCell: UITableViewCell {
    var iconView: UIImageView!
    private var isLoading: Bool = false
    private var isPlannedToShimmer: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 8
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            
            iconView.heightAnchor.constraint(equalToConstant: 144),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            self.iconView.image = image
            self.stopLoadingAnimation()
        }
    }
}

