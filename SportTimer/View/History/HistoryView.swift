//
//  HistoryView.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @StateObject private var viewModel: WorkoutViewModel
    @State private var searchText = ""
    @State private var selectedWorkoutType: WorkoutType? = nil
    @State private var showingFilterSheet = false
    @State private var dateRange: DateRange = .all
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Строка поиска и фильтра
                searchAndFilterSection
                
                // Список тренировок
                if filteredWorkouts.isEmpty {
                    emptyStateView
                } else {
                    workoutsList
                }
            }
            .background(Color.backgroundColor)
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .foregroundColor(.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheet(
                    selectedType: $selectedWorkoutType,
                    dateRange: $dateRange
                )
            }
        }
        .searchable(text: $searchText, prompt: "Поиск по заметкам...")
        .onAppear {
            viewModel.fetchWorkouts()
        }
    }
    
    private var filteredWorkouts: [Workout] {
        var workouts = viewModel.workouts
        
        if !searchText.isEmpty {
            workouts = workouts.filter { workout in
                (workout.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                viewModel.getWorkoutTypeFromString(workout.type ?? "").displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let selectedType = selectedWorkoutType {
            workouts = workouts.filter { workout in
                workout.type == selectedType.rawValue
            }
        }
        
        workouts = workouts.filter { workout in
            guard let date = workout.date else { return false }
            return dateRange.contains(date)
        }
        
        return workouts
    }
    
    private var groupedWorkouts: [String: [Workout]] {
        Dictionary(grouping: filteredWorkouts) { workout in
            guard let date = workout.date else { return "Неизвестная дата" }
            return DateFormatter.dayFormatter.string(from: date)
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: Spacing.small) {
            if selectedWorkoutType != nil || dateRange != .all {
                activeFiltersView
            }
        }
        .padding(.horizontal, Spacing.standard)
    }
    
    private var activeFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small) {
                if let selectedType = selectedWorkoutType {
                    FilterChip(
                        title: selectedType.displayName,
                        color: selectedType.color
                    ) {
                        selectedWorkoutType = nil
                    }
                }
                
                if dateRange != .all {
                    FilterChip(
                        title: dateRange.displayName,
                        color: .primaryColor
                    ) {
                        dateRange = .all
                    }
                }
            }
            .padding(.horizontal, Spacing.standard)
        }
    }
    
    private var workoutsList: some View {
        List {
            ForEach(groupedWorkouts.keys.sorted().reversed(), id: \.self) { day in
                Section(header: Text(day).font(.subtitleFont).foregroundColor(.textPrimaryColor)) {
                    ForEach(groupedWorkouts[day] ?? [], id: \.id) { workout in
                        HistoryWorkoutCard(workout: workout, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        deleteWorkouts(at: indexSet, in: day)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.standard) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.textSecondaryColor)
            
            Text("Нет тренировок")
                .font(.subtitleFont)
                .foregroundColor(.textSecondaryColor)
            
            Text("Тренировки будут отображаться здесь после их завершения")
                .font(.bodyFont)
                .foregroundColor(.textSecondaryColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
    
    private func deleteWorkouts(at offsets: IndexSet, in day: String) {
        guard let workouts = groupedWorkouts[day] else { return }
        
        for index in offsets {
            let workout = workouts[index]
            viewModel.deleteWorkout(workout)
        }
    }
}



struct FilterSheet: View {
    @Binding var selectedType: WorkoutType?
    @Binding var dateRange: DateRange
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: Spacing.standard) {
                // Фильтр по типу тренировки
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









#Preview {
    HistoryView(context: PersistenceController.preview.container.viewContext)
} 
