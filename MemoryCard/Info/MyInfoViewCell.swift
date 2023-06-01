//
//  MyInfoViewCell.swift
//  MemoryCard
//
//  Created by yc on 2023/06/02.
//

import SwiftUI

struct MyInfoViewCell: View {
    
    let title: String
    let textColor: Color
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 16.0)
            
            HStack {
                Text(title)
                    .font(.system(size: 18.0, weight: .medium))
                    .foregroundColor(textColor)
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 16.0)
        }
    }
}


struct MyInfoViewCell_Previews: PreviewProvider {
    static var previews: some View {
        MyInfoViewCell(title: "로그아웃", textColor: .red)
    }
}
