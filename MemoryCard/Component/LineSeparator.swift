//
//  LineSeparator.swift
//  MemoryCard
//
//  Created by yc on 2023/08/05.
//

import SwiftUI

struct LineSeparator: View {
    private let color = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: color))
                .frame(height: 1)
            
            Spacer()
                .frame(width: 32)
            
            Circle()
                .fill(Color(uiColor: color))
                .frame(height: 3)
            
            Spacer()
                .frame(width: 32)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: color))
                .frame(height: 1)
        }
    }
}
