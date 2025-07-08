//
//  FilterSheet.swift
//  SportTimer
//
//  Created by Георгий Борисов on 09.07.2025.
//
import SwiftUI

struct FilterSheet: View {
    @Binding var selectedType: WorkoutType?
    @Binding var dateRange: DateRange
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Spacing.standard) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Тип тренировки")
                        .font(.subtitleFont)
                        .foregroundColor(.textPrimaryColor)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.small) {
                            FilterTypeButton(
                                title: "Все",
                                isSelected: selectedType == nil,
                                color: .textSecondaryColor
                            ) {
                                selectedType = nil
                            }
                            
                            ForEach(WorkoutType.allCases, id: \.self) { type in
                                FilterTypeButton(
                                    title: type.displayName,
                                    isSelected: selectedType == type,
                                    color: type.color
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.standard)
                    }
                }
                
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("Период")
                        .font(.subtitleFont)
                        .foregroundColor(.textPrimaryColor)
                    
                    VStack(spacing: Spacing.small) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            FilterDateButton(
                                title: range.displayName,
                                isSelected: dateRange == range
                            ) {
                                dateRange = range
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(Spacing.standard)
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Готово") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
