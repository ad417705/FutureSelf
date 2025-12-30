//
//  ProfileSettingsView.swift
//  BudgetAI
//
//  Created by Claude on 12/26/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userProfile: UserProfile = UserProfile.load()
    @State private var showingEditProfile = false
    @State private var showingImagePicker = false

    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        // Profile Avatar
                        if let imageData = userProfile.profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.luxuryGold.opacity(0.3), lineWidth: 2)
                                )
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(DesignSystem.Colors.luxuryGold)
                                .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 8)
                        }

                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text(userProfile.name.isEmpty ? "Your Name" : userProfile.name)
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primaryText)

                            Text(userProfile.email.isEmpty ? "email@example.com" : userProfile.email)
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.secondaryText)

                            Text("Member since \(userProfile.accountCreationDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.tertiaryText)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.sm)

                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showingEditProfile = true
                    }) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                        }
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.accentGradient)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .shadow(color: DesignSystem.Colors.luxuryGold.opacity(0.3), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Profile")
                }

                // Income Preferences Section
                Section {
                    Toggle("Variable Income", isOn: $userProfile.hasVariableIncome)
                        .tint(DesignSystem.Colors.luxuryGold)
                        .onChange(of: userProfile.hasVariableIncome) { _ in
                            HapticManager.shared.selection()
                            userProfile.save()
                        }

                    if !userProfile.hasVariableIncome {
                        HStack {
                            Text("Monthly Income")
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Spacer()
                            Text(userProfile.monthlyIncome != nil ? "$\(String(format: "%.0f", userProfile.monthlyIncome!))" : "Not set")
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .onTapGesture {
                            HapticManager.shared.lightImpact()
                            showingEditProfile = true
                        }
                    }

                    if userProfile.hasVariableIncome {
                        Text("Your income will be averaged across months for more accurate insights.")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                } header: {
                    Text("Income Preferences")
                } footer: {
                    Text("Enable variable income if you're a freelancer, gig worker, or have inconsistent earnings.")
                }

                // AI Preferences Section
                Section {
                    Toggle("Predictive Alerts", isOn: $userProfile.enablePredictiveAlerts)
                        .tint(DesignSystem.Colors.luxuryGold)
                        .onChange(of: userProfile.enablePredictiveAlerts) { _ in
                            HapticManager.shared.selection()
                            userProfile.save()
                        }

                    Toggle("AI Suggestions", isOn: $userProfile.enableAISuggestions)
                        .tint(DesignSystem.Colors.luxuryGold)
                        .onChange(of: userProfile.enableAISuggestions) { _ in
                            HapticManager.shared.selection()
                            userProfile.save()
                        }

                    if userProfile.enableAISuggestions {
                        Picker("Suggestion Frequency", selection: $userProfile.aiSuggestionFrequency) {
                            ForEach(SuggestionFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.displayName).tag(frequency)
                            }
                        }
                        .onChange(of: userProfile.aiSuggestionFrequency) { _ in
                            HapticManager.shared.selection()
                            userProfile.save()
                        }
                    }
                } header: {
                    Text("AI Preferences")
                } footer: {
                    Text("Predictive alerts warn you before overspending. AI suggestions provide personalized financial insights.")
                }

                // App Information Section
                Section {
                    HStack {
                        Text("App Version")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }

                    HStack {
                        Text("Build")
                            .foregroundColor(DesignSystem.Colors.primaryText)
                        Spacer()
                        Text("2025.1")
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                } header: {
                    Text("About")
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(userProfile: $userProfile)
            }
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userProfile: UserProfile

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var monthlyIncome: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                if !userProfile.hasVariableIncome {
                    Section("Income") {
                        TextField("Monthly Income", text: $monthlyIncome)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.primaryBackground)
            .preferredColorScheme(.dark)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        HapticManager.shared.mediumImpact()
                        saveProfile()
                    }
                    .foregroundColor(DesignSystem.Colors.luxuryGold)
                }
            }
            .onAppear {
                name = userProfile.name
                email = userProfile.email
                if let income = userProfile.monthlyIncome {
                    monthlyIncome = String(format: "%.0f", income)
                }
            }
        }
    }

    private func saveProfile() {
        userProfile.name = name
        userProfile.email = email

        if !monthlyIncome.isEmpty, let income = Double(monthlyIncome) {
            userProfile.monthlyIncome = income
        }

        userProfile.save()
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    ProfileSettingsView()
}
