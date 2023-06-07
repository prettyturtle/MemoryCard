//
//  ProfileView.swift
//  MemoryCard
//
//  Created by yc on 2023/06/07.
//

import SwiftUI

struct ProfileView: View {
    
    @Binding var userEmail: String
    @Binding var cardZipCount: Int
    
    @State var isShowImagePicker = false
    @State var selectedImage: UIImage? = nil
    
    var body: some View {
        HStack(spacing: 0.0) {
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60.0, height: 60.0)
                    .foregroundColor(.secondary.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.secondary.opacity(0.3), lineWidth: 0.2)
                    )
                    .onTapGesture {
                        isShowImagePicker = true
                    }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60.0, height: 60.0)
                    .foregroundColor(.secondary.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.secondary.opacity(0.3), lineWidth: 0.2)
                    )
                    .onTapGesture {
                        isShowImagePicker = true
                    }
            }
            
            VStack(alignment: .leading, spacing: 0.0) {
                Text(userEmail)
                    .font(.system(size: 16.0, weight: .semibold))
                
                Text("카드 개수 : \(cardZipCount)")
                    .padding(.top, 8.0)
                    .font(.system(size: 16.0, weight: .semibold))
                    .foregroundColor(.secondary)
                
            }
            .padding(.horizontal, 16.0)
            
            Spacer()
        }
        .padding(16.0)
        
        .sheet(isPresented: $isShowImagePicker) {
            ImagePickerView { image in
                print(image)
                
                if let image = image {
                    selectedImage = image
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userEmail: .constant("bbb.bbb.bbb"), cardZipCount: .constant(10))
    }
}

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
