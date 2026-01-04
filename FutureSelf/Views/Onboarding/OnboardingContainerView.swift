//  OnboardingContainerView.swift
import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var coordinator: OnboardingCoordinator

    init() {
        _coordinator = StateObject(wrappedValue: OnboardingCoordinator(container: AppContainer.shared))
    }

    var body: some View {
        ZStack {
            switch coordinator.currentStep {
            case .welcome:
                WelcomeView(coordinator: coordinator)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .profilePhoto:
                ProfilePhotoView(coordinator: coordinator)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .goalSelection:
                GoalSelectionView(coordinator: coordinator)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .goalDetails:
                GoalDetailsView(coordinator: coordinator)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .goalWhy:
                GoalWhyView(coordinator: coordinator)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .visualization:
                VisualizationGenerationView(coordinator: coordinator)
                    .transition(.scale.combined(with: .opacity))
            case .complete:
                EmptyView() // Should never reach here - triggers dismiss
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: coordinator.currentStep)
    }
}
