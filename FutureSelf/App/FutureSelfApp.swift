//
//  FutureSelfApp.swift
//  FutureSelf
//
//  Created on 12/30/24.
//

import SwiftUI

@main
struct FutureSelfApp: App {
    @StateObject private var container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            if container.currentUser.onboardingComplete {
                ContentView()
                    .environmentObject(container)
                    .preferredColorScheme(.light)
            } else {
                OnboardingContainerView()
                    .environmentObject(container)
                    .preferredColorScheme(.light)
            }
        }
    }
}
