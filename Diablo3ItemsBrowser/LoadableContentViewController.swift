//
//  LoadableContentViewController.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit

class LoadableContentViewController: UIViewController {
    
    private var activityIndicator: UIActivityIndicatorView!
    private var indicatorAdded: Bool = false
    private var indicatorConstrains = [NSLayoutConstraint]()

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.alpha = 0

        indicatorConstrains = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }

    func startFullscreenSpinner() {
        if !indicatorAdded {
            view.addSubview(activityIndicator)
            NSLayoutConstraint.activate(indicatorConstrains)
        }
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.activityIndicator.alpha = 1
            self.hideContent()
        }
    }

    func stopFullscreenSpinner() {
        UIView.animate(withDuration: 0.25) {
            self.showContent()
            self.activityIndicator.alpha = 0
        } completion: { finished in
            guard finished else { return }
            if self.indicatorAdded {
                self.activityIndicator.removeFromSuperview()
                NSLayoutConstraint.deactivate(self.indicatorConstrains)
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func updateDataErrorHandler(error: DataProviderError?, onAlertClose: @escaping () -> Void = {}, completionHandler: @escaping (Bool) -> Void) -> Void {
        if let error = error {
            print("fetchItems error: \(error.description)")
            completionHandler(true)
            self.presentAlert(header: "Error", text: error.description, onClose: onAlertClose)
        } else {
            completionHandler(false)
        }
    }
    
    func updateData(completionHandler: @escaping (Bool) -> Void) { fatalError("Must override!") }
    func hideContent() { fatalError("Must override!") }
    func showContent() { fatalError("Must override!") }
}
