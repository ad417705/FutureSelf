//  WelcomeView.swift
import SwiftUI

struct WelcomeView: View {
    @ObservedObject var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App logo/icon
            Image(systemName: "target")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .padding(.bottom, 16)

            // Welcome title
            Text("Welcome to FutureSelf")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Description
            Text("Visualize your financial goals and watch your future come to life as you save")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Get Started button
            Button(action: {
                coordinator.advance()
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .padding()
    }
}
