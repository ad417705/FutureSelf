//  ImagePicker.swift
import SwiftUI
import PhotosUI

// MARK: - Image Compression Utilities
extension UIImage {
    /// Compress and resize image to reasonable size for storage
    func compressedImageData(maxSizeKB: Int = 500, maxDimension: CGFloat = 1024) -> Data? {
        // Resize if needed
        var image = self
        let maxSize = max(size.width, size.height)
        if maxSize > maxDimension {
            let scale = maxDimension / maxSize
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            draw(in: CGRect(origin: .zero, size: newSize))
            image = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
        }

        // Try different compression qualities to stay under size limit
        var compression: CGFloat = 0.9
        var data = image.jpegData(compressionQuality: compression)

        while let imageData = data, imageData.count > maxSizeKB * 1024 && compression > 0.1 {
            compression -= 0.1
            data = image.jpegData(compressionQuality: compression)
        }

        return data
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage,
                           let data = uiImage.compressedImageData() {
                            self.parent.imageData = data
                        }
                    }
                }
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.dismiss()

            if let uiImage = info[.originalImage] as? UIImage,
               let data = uiImage.compressedImageData() {
                parent.imageData = data
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
