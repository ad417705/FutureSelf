//  GoalWhyView.swift
import SwiftUI

struct GoalWhyView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var currentQuestion = 0
    @State private var answers: [String] = ["", "", ""]

    private var questions: [String] {
        switch coordinator.progress.collectedData.goalType {
        case .travel:
            return [
                "Where do you want to go?",
                "What will you do when you get there?",
                "How will achieving this trip change your life?"
            ]
        case .moveOut:
            return [
                "What kind of place do you want to live in?",
                "Where do you imagine living?",
                "What will having your own place mean to you?"
            ]
        case .emergencyFund:
            return [
                "Why is building an emergency fund important to you?",
                "How will you feel knowing you have a safety net?",
                "What would having 30 days of expenses saved change for you?"
            ]
        case .debtFree:
            return [
                "What debt are you working to pay off?",
                "How will being debt-free change your life?",
                "What will you do once you're free from this debt?"
            ]
        default:
            return [
                "Why is this goal important to you?",
                "What will your life look like when you achieve it?",
                "How will you feel when you reach this goal?"
            ]
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<questions.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentQuestion ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)

            // Question section
            VStack(alignment: .leading, spacing: 16) {
                Text("Tell me about your goal")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(questions[currentQuestion])
                    .font(.headline)
                    .foregroundColor(.secondary)

                TextField("Your answer", text: $answers[currentQuestion], axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                    .padding(.top, 8)
            }
            .padding()

            Spacer()

            // Navigation buttons
            HStack(spacing: 12) {
                if currentQuestion > 0 {
                    Button("Back") {
                        currentQuestion -= 1
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }

                Button(currentQuestion < questions.count - 1 ? "Next" : "Continue") {
                    if currentQuestion < questions.count - 1 {
                        currentQuestion += 1
                    } else {
                        // Combine all answers
                        let combined = questions.enumerated().map { index, question in
                            "\(question) \(answers[index])"
                        }.joined(separator: " ")

                        coordinator.progress.collectedData.detailedWhy = combined

                        // Extract specific details from answers for structured data
                        extractGoalDetails()

                        coordinator.advance()
                    }
                }
                .disabled(answers[currentQuestion].isEmpty)
                .frame(maxWidth: .infinity)
                .padding()
                .background(answers[currentQuestion].isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .padding()
    }

    private func extractGoalDetails() {
        // Parse answers to extract structured details
        var details = GoalDetails(additionalDetails: [:])

        switch coordinator.progress.collectedData.goalType {
        case .travel:
            details.location = answers[0]
        case .moveOut:
            details.location = answers[1]
        default:
            break
        }

        coordinator.progress.collectedData.goalDetails = details
    }
}
