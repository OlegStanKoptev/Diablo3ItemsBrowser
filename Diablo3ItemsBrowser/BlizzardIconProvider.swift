//
//  BlizzardIconProvider.swift
//  Diablo3ItemsBrowser
//
//  Created by Коптев Олег Станиславович on 17.03.2022.
//

import UIKit

class BlizzardIconProvider: IconProvider {
    public init() {}
    private var cachedImages = NSCache<NSString, UIImage>()
    private var loadingResponses: [String: [IconCompletionHandler]] = [:]

    func retrieveIcon(iconName: String, size: IconSize, completionHandler: @escaping IconCompletionHandler) {
        if let cachedImage = cachedImages.object(forKey: NSString(string: iconName)) {
            DispatchQueue.main.async {
                completionHandler(cachedImage, nil)
            }
            return
        }
        
        if loadingResponses[iconName] != nil {
            loadingResponses[iconName]?.append(completionHandler)
            return
        } else {
            loadingResponses[iconName] = [completionHandler]
        }
        
        ServiceContext.shared.repository.getIconData(of: iconName, size: size) { result in
            switch result {
            case .success(let data):
                guard let blocks = self.loadingResponses[iconName] else { return }
                guard let image = UIImage(data: data) else {
                          NSLog("Image request returned bad data")
                    
                    for block in blocks {
                        DispatchQueue.main.async {
                            block(
                                UIImage(systemName: "xmark.octagon")!
                                    .withTintColor(.systemFill, renderingMode: .alwaysOriginal),
                                nil
                            )
                        }
                    }
                    self.loadingResponses.removeValue(forKey: iconName)
                    return
                }
                
                self.cachedImages.setObject(image, forKey: NSString(string: iconName), cost: data.count)
                
                for block in blocks {
                    DispatchQueue.main.async {
                        block(image, nil)
                    }
                }
                self.loadingResponses.removeValue(forKey: iconName)
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(nil, .innerError(error))
                }
            }
        }
    }
}
