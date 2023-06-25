//
//  AppIconConfigView.swift
//  MemoryCard
//
//  Created by yc on 2023/06/25.
//

import SwiftUI

struct AppIconConfigView: View {
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    private let iconNames = [
        "AppIcon_Black",
        "AppIcon_Pink",
        "AppIcon_Purple",
        "AppIcon_Blue",
        "AppIcon_Yellow"
    ]
    
    @State var currentAppIcon: String?
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(iconNames, id: \.self) { iconName in
                        if let image = UIImage(named: iconName) {
                            let imageSize = (proxy.size.width - 48.0) / 2.0
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imageSize, height: imageSize)
                                .overlay {
                                    if let currentAppIcon = currentAppIcon,
                                       currentAppIcon == iconName {
                                        RoundedRectangle(cornerRadius: 12.0)
                                            .stroke(.orange, lineWidth: 2.0)
                                    } else {
                                        RoundedRectangle(cornerRadius: 12.0)
                                            .stroke(.gray.opacity(0.3), lineWidth: 1.0)
                                    }
                                }
                                .onTapGesture {
                                    currentAppIcon = iconName
                                    
                                    let selectedIconName = iconName == "AppIcon_Black" ? nil : iconName
                                    
                                    UIApplication
                                        .shared
                                        .setAlternateIconName(selectedIconName) { error in
                                            if let error = error {
                                                return
                                            }
                                            
                                            UserDefaults.standard.set(selectedIconName, forKey: "APP_ICON")
                                        }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("앱 아이콘 변경")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            let currAppIcon = UserDefaults.standard.string(forKey: "APP_ICON")
            
            currentAppIcon = currAppIcon ?? iconNames.first
        }
    }
}


struct AppIconConfigView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconConfigView()
    }
}
