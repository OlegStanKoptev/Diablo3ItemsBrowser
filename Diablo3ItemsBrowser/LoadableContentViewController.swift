//
//  LoadableContentViewController.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import UIKit

/// Custom view controller with fullscreen spinner loader before showing data and error handler.
/// Must be overrided methods:
///     - updateData
///     - hideContent
///     - showContent
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
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.activityIndicator.alpha = 1
            self?.hideContent()
        }
    }

    func stopFullscreenSpinner() {
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.showContent()
            self.activityIndicator.alpha = 0
        } completion: {  [weak self] finished in
            guard finished, let self = self else { return }
            if self.indicatorAdded {
                self.activityIndicator.removeFromSuperview()
                NSLayoutConstraint.deactivate(self.indicatorConstrains)
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func updateDataErrorHandler(error: DataProviderError?, onAlertClose: @escaping () -> Void = {}, completionHandler: @escaping (Bool) -> Void) -> Void {
        DispatchQueue.main.async { [weak self] in
            self?.stopFullscreenSpinner()
        }
        if let error = error {
            print("fetchItems error: \(error.localizedDescription)")
            completionHandler(true)
            self.presentAlert(header: "Error", text: error.localizedDescription, onClose: onAlertClose)
        } else {
            completionHandler(false)
        }
    }
    
    func updateData(completionHandler: @escaping (Bool) -> Void) { fatalError("Must override!") }
    func hideContent() { fatalError("Must override!") }
    func showContent() { fatalError("Must override!") }
}
