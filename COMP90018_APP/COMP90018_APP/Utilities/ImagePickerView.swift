//
//  ImagePickerView.swift
//  COMP90018_APP
//
//  Created by frank w on 14/10/2023.
//

import SwiftUI
import PhotosUI
import BSImagePicker



struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var completionHandler: (UIImage?) -> Void
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completionHandler(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Reference: https://github.com/mikaoj/BSImagePicker/issues/265#issuecomment-636692230

public struct ImagePickerCoordinatorView {
    var maxImageCount: Int
    @Binding var images: [UIImage]

}

extension ImagePickerCoordinatorView: UIViewControllerRepresentable {


    public typealias UIViewControllerType = ImagePickerController

    public func makeUIViewController(context: Context) -> ImagePickerController {
        let picker = ImagePickerController()

        picker.settings.selection.max = maxImageCount
        picker.settings.selection.unselectOnReachingMax = false
        picker.settings.theme.selectionStyle = .numbered
        picker.settings.fetch.assets.supportedMediaTypes = [.image]
        picker.imagePickerDelegate = context.coordinator

        return picker
    }

    public func updateUIViewController(_ uiViewController: ImagePickerController, context: Context) {

    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

extension ImagePickerCoordinatorView {
    public class Coordinator: ImagePickerControllerDelegate {
        private let parent: ImagePickerCoordinatorView

        public init(_ parent: ImagePickerCoordinatorView) {
            self.parent = parent
        }
        
        private func manageGrayOverlay(for imagePicker: ImagePickerController, show: Bool) {
            // If the overlay already exists, remove it
            if let existingOverlay = imagePicker.view.viewWithTag(999) {
                existingOverlay.removeFromSuperview()
            }
            
            // If show is true, add the overlay
            if show {
                let grayOverlay = UIView(frame: imagePicker.view.bounds)
                grayOverlay.backgroundColor = UIColor(.gray.opacity(0.3))
                grayOverlay.tag = 999  // Tag to identify the overlay
                grayOverlay.isUserInteractionEnabled = false  // Let touches pass through
                
                imagePicker.view.addSubview(grayOverlay)
            }
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset) {
            if imagePicker.settings.selection.max == imagePicker.selectedAssets.count{
                // Add gray overlay when meet the maximum limit
                manageGrayOverlay(for: imagePicker, show: true)
            }
            print("Selected")
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset) {
            // Check if the number of selected images is less than the maximum limit
                if imagePicker.settings.selection.max > imagePicker.selectedAssets.count {
                    // Remove gray overlay
                    manageGrayOverlay(for: imagePicker, show: false)
                }
            print("Deselected")
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset]) {
            print("Finished with selections")
            for asset in assets {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    if let img = result {
                        self.parent.images.append(img)
                    }
                })
        }
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
            print("Canceled with selections")
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
            print("Did Reach Selection Limit: \(count)")
            let alert = UIAlertController(title: "Limit Reached", message: "You can select up to \(count) images only.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            imagePicker.present(alert, animated: true, completion: nil)
        }
    }
}


