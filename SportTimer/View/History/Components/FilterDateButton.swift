//
//  FilterDateButton.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//
import SwiftUI

struct FilterDateButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.bodyFont)
                    .foregroundColor(.textPrimaryColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.primaryColor)
                }
            }
            .padding(Spacing.standard)
            .background(isSelected ? Color.primaryColor.opacity(0.1) : Color.white)
            .cornerRadius(CornerRadius.card)
        }
    }
}
