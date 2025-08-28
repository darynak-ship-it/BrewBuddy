//
//  KombuchaTrackrApp.swift
//  KombuchaTrackr
//
//  Created by Daryna Kalnichenko on 8/4/25.
//

import SwiftUI
import UserNotifications

@main
struct KombuchaTrackrApp: App {
    @StateObject private var fermentationManager = FermentationManager()
    @State private var showingNotificationPermission = false
    @State private var hasRequestedPermission = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fermentationManager)
                .onAppear {
                    checkNotificationPermissions()
                }
                .preferredColorScheme(.light) // Force light mode to prevent dark mode issues
        }
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    if !hasRequestedPermission {
                        hasRequestedPermission = true
                        showingNotificationPermission = true
                    }
                case .denied:
                    // User denied notifications, show alert
                    showingNotificationPermission = true
                case .authorized, .provisional, .ephemeral:
                    // Notifications are authorized
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}
