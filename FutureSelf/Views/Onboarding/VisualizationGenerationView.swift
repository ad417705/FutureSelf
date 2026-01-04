//  VisualizationGenerationView.swift
import SwiftUI

struct VisualizationGenerationView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @EnvironmentObject var container: AppContainer
    @State private var isGenerating = false
    @State private var generationComplete = false
    @State private var error: Error?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if isGenerating {
                VStack(spacing: 24) {
                    ProgressView()
                        .scaleEffect(1.5)

                    Text("Creating your FutureSelf vision...")
                        .font(.headline)

                    Text("This may take a moment")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if generationComplete {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text("Your FutureSelf is ready!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Let's start building your future together")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Button("Get Started") {
                        Task {
                            try? await coordinator.complete()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            } else if let error = error {
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)

                    Text("Oops! Something went wrong")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(error.localizedDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task {
                            await generateVisualization()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding()
        .task {
            await generateVisualization()
        }
    }

    private func generateVisualization() async {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            // Simulate generation (actual generation happens in coordinator.complete())
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            generationComplete = true
        } catch {
            self.error = error
        }
    }
}
