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
    
    private var profileImage: Image {
        if let selectedImage = selectedImage {
            return Image(uiImage: selectedImage)
        } else {
            return Image(systemName: "person.circle.fill")
        }
    }
    
    var body: some View {
        HStack(spacing: 0.0) {
            
            profileImage
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
                    
                    saveImage(img: image)
                }
            }
        }
        .onAppear {
            if let profileImageData = UserDefaults.standard.data(forKey: "PROFILE_IMG_DATA"),
               let profileImage = UIImage(data: profileImageData) {
                selectedImage = profileImage
            }
        }
    }
    
    
    private func saveImage(img: UIImage) {
        let imgData = img.pngData()
        // TODO: - 파이어베이스 프로필 이미지 저장
        UserDefaults.standard.setValue(imgData, forKey: "PROFILE_IMG_DATA")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userEmail: .constant("bbb.bbb.bbb"), cardZipCount: .constant(10))
    }
}
