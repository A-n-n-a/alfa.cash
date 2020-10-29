//
//  AppDelegate.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManager
import Firebase
import FirebaseDynamicLinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        
//        FirebaseManager.shared.configureFCM()
        
        if !UserDefaults.standard.bool(forKey: Constants.Main.udFirstRun){
            if KeychainWrapper.standart.clearKeychain() {
                UserDefaults.standard.set(true, forKey: Constants.Main.udFirstRun)
            } else {
                EventLogger.log(issue: "Keychain clearing failed", severity: .error)
            }
        }

        if #available(iOS 13.0, *) {
            // In iOS 13 setup is done in SceneDelegate
        } else {
            Presenter.showCustomScreen()
        }
        
        DynamicLinks.performDiagnostics(completion: nil)
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if let link = dynamiclink {
                print("DYNAMIC LINK: ", link)
            }
        }

        return handled
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //Called when user installed the app via referral link
        let dynamicLink =   DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
        if let dynamicLink = dynamicLink, let query = dynamicLink.url?.query {
            #if DEBUG
            print("Dynamic link : \(dynamicLink.url)")
            #endif
            let components = query.components(separatedBy: "=")
            if let key = components.first,
                key == "alfaRefId",
                let value = components.last {
                UserDefaults.standard.set(value, forKey: Constants.Main.udReferralId)
            }
            return true
        }
        return false
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AlfaCash")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

// MARK: - Handling APNS

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        #if DEBUG
        print("Device Token: \(token)")
        #endif
        FirebaseManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        FirebaseManager.shared.didFailToRegisterForRemoteNotifications(error: error)
    }
}