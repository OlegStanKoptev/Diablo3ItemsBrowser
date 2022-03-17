//
//  IconProvider.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 16.03.2022.
//

import UIKit

typealias IconCompletionHandler = (UIImage?, DataProviderError?) -> Void

protocol IconProvider {
    func retrieveIcon(iconName: String, size: IconSize, completionHandler: @escaping IconCompletionHandler)
}
