//
//  FirebaseManager.swift
//  alfa.cash
//
//  Created by Anna on 5/4/20.
//  Copyright © 2020 Anna. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import UserNotifications
import MobileCoreServices
import FirebaseMessaging

final class FirebaseManager: NSObject {
    
    /// Singleton object
    public static let shared = FirebaseManager()
    
    var bundle: String?
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
    override private init() {
        
        FirebaseApp.configure()
    }
    
    func subscribeTo(id: Int) {
        Messaging.messaging().subscribe(toTopic: "\(id)")
    }
    
    func unsubscribeFrom(id: Int) {
        Messaging.messaging().unsubscribe(fromTopic: "\(id)") 
    }
}

// MARK: - Configuring FCM
extension FirebaseManager: UNUserNotificationCenterDelegate, MessagingDelegate {
    func configureFCM() {
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in
                
        })
        UIApplication.shared.registerForRemoteNotifications()
        
    }
    
    func didRegisterForRemoteNotifications(deviceToken token: Data) {
        print("[FirebaseManager] didRegisterForRemoteNotifications: \(token)")
    }
    
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("[FirebaseManager] didFailToRegisterForRemoteNotifications: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("[PMFirebaseManager] didReceiveResponse: \(userInfo)")
        

        
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("[PMFirebaseManager] didReceiveMessagingToken: \(fcmToken)")
//        UserDefaults.standard.set(fcmToken, forKey: "PushToken")
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("[PMFirebaseManager] didReceiveRemoteMessage: \(remoteMessage.appData)")
    }
}

