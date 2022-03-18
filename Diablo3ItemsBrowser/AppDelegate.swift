//
//  AppDelegate.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 09.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let repo = ApiRepository().configured {
            $0.authURL =  URL(string: "https://eu.battle.net/oauth")!
            $0.dataURL = URL(string: "https://eu.api.blizzard.com/d3/data/")!
            $0.iconsURL = URL(string: "http://media.blizzard.com/d3/icons/items/")!
            $0.clientId = "6e8f77dda6f54584a903f946fbce3a1c"
            $0.clientSecret = "Zru74EK8ywVBmoAf38A3VAwoSPAluRaO"
            $0.tokenStorage = .init()
        }
        
        ServiceContext.configure {
            $0.repository = repo
            $0.repository.tokenStorage = .init()
            $0.persistentContainer = .newContainerForCurrentProject()
            $0.itemTypesService = BlizzardItemTypesService()
            $0.itemsService = BlizzardItemsService(iconProvider: BlizzardIconProvider())
            $0.itemDescriptionService = BlizzardItemDescriptionService(iconProvider: BlizzardIconProvider())
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

