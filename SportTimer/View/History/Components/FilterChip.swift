//
//  FilterChip.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.secondaryTextFont)
                .foregroundColor(color)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    HStack {
        FilterChip(
            title: "Кардио",
            color: .primaryColor,
            onRemove: {}
        )
        
        FilterChip(
            title: "Эта неделя",
            color: .successColor,
            onRemove: {}
        )
    }
    .padding()
} 