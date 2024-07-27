//
//  TaskDetails+Feature.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 20/08/23.
//

import ComposableArchitecture
import Foundation

extension Note {
    
    @Reducer
    struct Feature {
        @ObservableState
        struct State: Equatable {
            var blocks: IdentifiedArrayOf<NoteItem.Feature.State> = []
        }
        
        @CasePathable
        enum Action: ViewAction, Equatable {
            
            case blocks(IdentifiedActionOf<NoteItem.Feature>)
            
            case onAppear
            case closeTapped
            
            case moveToLast
            case saveNote(Task.Model)
            
            
            case view(View)

            enum View: Equatable {
                case addBlockTapped
                case removeBlockTapped(UUID)
            }
        }
        
        @Dependency(\.dismiss) var dismiss
        
        var body: some Reducer<State, Action> {
            Reduce(self.core)
                .forEach(\.blocks, action: \.blocks) {
                    NoteItem.Feature()
                }
                ._printChanges()
        }
        
        private func core(into state: inout State, action: Action) -> Effect<Action> {
            switch action {
            case .onAppear:
                
                return .none
            case .closeTapped:
                return .run { send in
                    await dismiss()
                }
            case .view(.addBlockTapped):
                // TODO: Configurar corretamente o metadata
                state.blocks.append(.init(block: .init(type: .text, metadata: .init(author: "Rodrigo"))))
                
                return .none
            case .view(.removeBlockTapped(let uid)):
                state.blocks[id: uid] = nil
                
                return .none
            default:
                return .none
            }
        }
    }
}
