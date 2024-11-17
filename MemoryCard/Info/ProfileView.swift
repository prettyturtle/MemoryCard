//
//  ProfileView.swift
//  MemoryCard
//
//  Created by yc on 2023/06/07.
//

import SwiftUI

struct ProfileView: View {
	
	@Binding var currentUser: User
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
				Text(currentUser.name ?? currentUser.email)
					.font(UIFont.Pretendard.m16.font)
				
				Text("카드 개수 : \(cardZipCount)")
					.padding(.top, 8.0)
					.font(UIFont.Pretendard.m16.font)
					.foregroundColor(.secondary)
				
			}
			.padding(.horizontal, 16.0)
			
			Spacer()
		}
		.padding(16.0)
		
		.sheet(isPresented: $isShowImagePicker) {
			ImagePickerView { image in
				
				if let image = image {
					selectedImage = image
					
					saveImage(img: image)
				}
			}
		}
		.onAppear {
			fetchImage(user: currentUser)
		}
		.onChange(of: currentUser) { newCurrentUser in
			fetchImage(user: newCurrentUser)
		}
	}
	
	
	private func saveImage(img: UIImage) {
		if let imgData = img.jpegData(compressionQuality: 0.1) {
			UserDefaults.standard.setValue(
				imgData,
				forKey: "PROFILE_IMG_DATA_\(currentUser.id)"
			)
			
			Task {
				do {
					let imageURL = try await DBManager.shared.saveImage(
						data: imgData,
						mIdx: currentUser.id
					)
					
					currentUser.profileImgURL = imageURL
					
					DBManager.shared.save(
						.user,
						documentName: currentUser.id,
						data: currentUser
					) {_ in}
				} catch {
					print("💩 ERROR : \(error.localizedDescription)")
				}
			}
		}
	}
	
	private func fetchImage(user: User) {
		if let profileImageData = UserDefaults.standard.data(forKey: "PROFILE_IMG_DATA_\(user.id)"),
		   let profileImage = UIImage(data: profileImageData) {
			selectedImage = profileImage
		} else {
			if let imageURLString = user.profileImgURL,
			   let imageURL = URL(string: imageURLString) {
				Task {
					do {
						let (data, _) = try await URLSession.shared.data(from: imageURL)
						
						UserDefaults.standard.setValue(data, forKey: "PROFILE_IMG_DATA_\(user.id)")
						
						let profileImage = UIImage(data: data)
						
						selectedImage = profileImage
					} catch {
						print("ERROR : 저장된 이미지가 없음")
						print("ERROR : \(error.localizedDescription)")
					}
				}
			}
		}
	}
}

struct ProfileView_Previews: PreviewProvider {
	static var previews: some View {
		ProfileView(currentUser: .constant(.init(id: "123123", email: "bbb.bbb.bbb")), cardZipCount: .constant(10))
	}
}
