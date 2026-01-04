//  ProfilePhotoView.swift
import SwiftUI

struct ProfilePhotoView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var showingImagePicker = false
    @State private var showingCamera = false

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Let's Create Your FutureSelf")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Upload a photo of yourself to see your future come to life")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Photo display
            if let photoData = coordinator.progress.collectedData.profilePhoto,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    )
            }

            Spacer()

            // Photo selection buttons
            VStack(spacing: 12) {
                Button(action: { showingCamera = true }) {
                    Label("Take Photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: { showingImagePicker = true }) {
                    Label("Choose from Library", systemImage: "photo.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            // Continue button
            Button("Continue") {
                coordinator.advance()
            }
            .disabled(coordinator.progress.collectedData.profilePhoto == nil)
            .frame(maxWidth: .infinity)
            .padding()
            .background(coordinator.progress.collectedData.profilePhoto != nil ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(imageData: $coordinator.progress.collectedData.profilePhoto)
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(imageData: $coordinator.progress.collectedData.profilePhoto)
        }
    }
}
