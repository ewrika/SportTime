//
//  MainView.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(context: viewContext, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)
            
            TimerView(context: viewContext)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Таймер")
                }
                .tag(1)
            
            HistoryView(context: viewContext)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("История")
                }
                .tag(2)
            
            ProfileView(context: viewContext)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
                .tag(3)
        }
        .accentColor(.primaryColor)
    }
}

#Preview {
    MainView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
