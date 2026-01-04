//  FutureSelfScoreCard.swift
import SwiftUI

struct FutureSelfScoreCard: View {
    let score: Int
    let activeGoal: Goal?

    private var stars: Int {
        switch score {
        case 0..<20: return 1
        case 20..<40: return 2
        case 40..<60: return 3
        case 60..<80: return 4
        default: return 5
        }
    }

    private var scoreColor: Color {
        switch score {
        case 0..<40: return .red
        case 40..<70: return .orange
        default: return .green
        }
    }

    var body: some View {
        Group {
            if let goal = activeGoal {
                NavigationLink(destination: FutureSelfView(goal: goal)) {
                    scoreCardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                scoreCardContent
            }
        }
    }

    private var scoreCardContent: some View {
        VStack(spacing: 12) {
            HStack {
                Text("FutureSelf Score")
                    .font(.headline)

                Spacer()

                if activeGoal != nil {
                    HStack(spacing: 4) {
                        Text("View Vision")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }

            Text("\(score)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(scoreColor)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.6), value: score)

            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < stars ? "star.fill" : "star")
                        .foregroundColor(index < stars ? .yellow : .gray)
                        .font(.title3)
                        .animation(.spring(duration: 0.4).delay(Double(index) * 0.1), value: stars)
                }
            }

            Text(scoreMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let goal = activeGoal, goal.futureVision != nil {
                HStack(spacing: 6) {
                    Image(systemName: goal.type.icon)
                        .font(.caption2)
                    Text(goal.name)
                        .font(.caption)
                    }
                .foregroundColor(.secondary)
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var scoreMessage: String {
        switch score {
        case 0..<40: return "Keep going! Small steps matter."
        case 40..<70: return "You're making progress!"
        case 70..<85: return "Great job! Keep it up!"
        default: return "Amazing! You're crushing it!"
        }
    }
}
