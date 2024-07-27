//
//  Home+View.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 26/07/23.
//

import ComposableArchitecture
import SwiftUI

extension Home {
    struct View: SwiftUI.View {
        let store: StoreOf<Feature>
        
        var body: some SwiftUI.View {
            
            NavigationStackStore(store.scope(state: \.destination, action: \.destination)) {
                TaskCalendar.View(store: store.scope(state: \.taskCalendar, action: \.taskCalendar))
                    .transition(.scale)
            } destination: {
                switch $0 {
                case .search:
                    CaseLet(/Destination.State.search, action: Destination.Action.search) {
                        Search.View(store: $0)
                    }
                    
                case .settings:
                    CaseLet(/Destination.State.settings, action: Destination.Action.settings) {
                        Settings.View(store: $0)
                    }
                    
                case .note:
                    CaseLet(/Destination.State.note, action: Destination.Action.note) { store in
//                        Note.View(store: $0)
                        UIViewControllerRepresenting {
                            Note.ViewController(store: store)
                        }
                    }
                }
            }
            .sheet(store: store.scope(state: \.$schedule, action: \.schedule)) { store in
                Schedule.View(store: store)
                    .presentationDetents([.medium])
            }
        }
    }
}

