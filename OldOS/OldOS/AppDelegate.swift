//
//  AppDelegate.swift
//  iOS11Remake
//
//  Created by Samuel Bowers on 5/20/2026.
//

import UIKit
import CoreData
import OAuth2

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "<ENTER YOURS HERE>",
        "authorize_uri": "https://accounts.google.com/o/oauth2/v2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "scope": "https://mail.google.com/ openid email profile",
        "redirect_uris": ["<ENTER YOURS HERE>:/oauthredirect"],
        "secret_in_body": true,
        "keychain": true
    ])

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let userDefaults = UserDefaults.standard
        userDefaults.register(
            defaults: [
                // Updated default wallpapers to match iOS 11 aesthetic references
                "Lock_Wallpaper": "iOS11_Default_Wallpaper", 
                "Home_Wallpaper": "iOS11_Default_Wallpaper",
                "Camera_Wallpaper_Lock": false,
                "Camera_Wallpaper_Home": false,
                
                // Bookmarks updated to reflect iOS 11 era resources
                "bookmarks": [
                    "https://apple.com": "Apple",
                    "https://yahoo.com": "Yahoo!",
                    "https://google.com": "Google",
                    "https://manuals.info.apple.com/MANUALS/1000/MA1819/en_US/iphone_ios11_user_guide.pdf": "iPhone User Guide (iOS 11)",
                    "https://support.apple.com/ios": "iOS Support"
                ],
                "webpages": [
                    "0": "https://google.com"
                ],
                "weather_cities": [
                    "0": "Cupertino, United States", 
                    "1": "New York, United States"
                ],
                "weather_mode": "imperial",
                "stock_mode": "Price",
                "stocks": ["AAPL", "GOOG", "NVDA", "TSLA", "T", "MSFT", "AMZN", "NFLX", "META", "INTC", "ORCL"]
            ]
        )
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        oauth2.authParameters = [
            "access_type": "offline",
            "prompt": "consent"
        ]
        oauth2.authConfig.authorizeEmbedded = false
        oauth2.authConfig.ui.useSafariView = false
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
    
    // MARK: - Core Data Stack

    lazy var persistentEmailContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Emails")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
