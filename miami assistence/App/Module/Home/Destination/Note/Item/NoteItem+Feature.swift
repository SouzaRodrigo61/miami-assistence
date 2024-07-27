//
//  NoteItem+Feature.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 25/09/23.
//

import ComposableArchitecture
import Foundation

extension NoteItem {
    @Reducer
    struct Feature {
        
        @ObservableState
        struct State: Equatable, Identifiable {
            var id = UUID()
            var hasFocus: Bool = true
            var blockForChangeKeyboard: Bool = false
            
            var block: Note.Block
        }
        
        @CasePathable
        enum Action: Equatable {
            case onAppear
            case blockKeyboard(Bool)
            
            case blockContent(String, NSAttributedString)
        }
        
        var body: some Reducer<State, Action> {
            Reduce { state, action in
                switch action {
                case .blockKeyboard(let isBlock):
                    state.blockForChangeKeyboard = isBlock
                    
                    return .none
                case let .blockContent(content, attribute):
                    state.block.content = content
                    state.block.contentCache = attribute
                    
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}

