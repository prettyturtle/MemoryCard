//
//  ImagePickerView.swift
//  MemoryCard
//
//  Created by yc on 2023/06/08.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    
    let didFinished: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        print("1.1.1.1.HELLO \(uiViewController), \(context)")
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    final class Coordinator: PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            guard let itemProvider = results.first?.itemProvider else {
                parent.didFinished(nil)
                
                picker.dismiss(animated: true)
                return
            }
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.parent.didFinished(nil)
                            
                            picker.dismiss(animated: true)
                            return
                        }
                        
                        if let image = image as? UIImage {
                            self?.parent.didFinished(image)
                            
                            picker.dismiss(animated: true)
                            return
                        }
                    }
                }
            }
        }
        
        var parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
    }
}
