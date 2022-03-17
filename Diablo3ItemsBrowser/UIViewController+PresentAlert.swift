//
//  UIViewController+PresentAlert.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit

extension UIViewController {
    func presentAlert(header: String? = nil, text: String? = nil, onClose: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: header ?? "Alert", message: text ?? "This is an alert.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                onClose()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
