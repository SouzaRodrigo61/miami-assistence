//
//  Task+Feature.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 18/08/23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

extension Task {
    struct Feature: Reducer {
        struct State: Equatable {
            var item: IdentifiedArrayOf<TaskItem.Feature.State> = []
            var empty: TaskEmpty.Feature.State?
        }
        
        enum Action: Equatable {
            case item(TaskItem.Feature.State.ID, TaskItem.Feature.Action)
            case empty(TaskEmpty.Feature.Action)
            
            case goToDetail(Task.Model)
            case showTaskCreate
            
            case onAppear
        }
        
        var body: some Reducer<State, Action> {
            Reduce(self.core)
                .forEach(\.item, action: /Action.item) {
                    TaskItem.Feature()
                }
                .ifLet(\.empty, action: /Action.empty) {
                    TaskEmpty.Feature()
                }
        }
    }
}

// MARK: - Reduce Actions
extension Task.Feature {
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .item(_, .setCurrentlyDragged(task)):
            return setCurrentlyTaskWhenDragging(into: &state, task: task)
        case .item(_, .moveCurrentlyDragged(_, _)):
            return .none
            
        case .onAppear:
            if state.item.isEmpty {
                state.empty = .init()
            }
            
            return .none
        
        default:
            return .none
        }
    }
}


// MARK: - Drag and Drop item on the List
extension Task.Feature {
    
    private func setCurrentlyTaskWhenDragging(into state: inout State, task: Task.Model) -> Effect<Action> {
//        guard let sourceIndex = state.item.firstIndex(where: { $0.task.id == task.id }) else { return .none }
//        state.item[sourceIndex].draggingTaskId = task.id
//        state.item[sourceIndex].isDragging = false
        
        return .none
    }
    
    private func whenDraggingTaskMoveAndChangeTime(into state: inout State, task: Task.Model) -> Effect<Action> {

        UIImpactFeedbackGenerator.feedback(.soft)
        
//        guard let currentlyTask = state.item.first(where: { $0.draggingTaskId != nil }) else { return .none }
//        guard let sourceIndex = state.item.firstIndex(where: { $0.task.id == currentlyTask.task.id }) else { return .none }
//        guard let destinationIndex = state.item.firstIndex(where: { $0.task.id == task.id }) else { return .none }
//        
//        state.item[sourceIndex].isDragging = true
//        state.item[sourceIndex].draggingTaskId = currentlyTask.task.id
//        
//        let sourceDestination = state.item[destinationIndex]
//        let sourceItem = state.item.remove(at: sourceIndex)
//        
//        state.item.insert(sourceItem, at: destinationIndex)
//        
//        guard let tempDest = state.item.firstIndex(where: { $0.id == sourceDestination.id }) else { return .none }
//        guard let tempFoward = state.item.firstIndex(where: { $0.id == sourceItem.id }) else { return .none }
//        
//        state.item[tempDest].task.date = sourceItem.task.date
//        state.item[tempDest].minY = sourceItem.minY
//        state.item[tempDest].maxY = sourceItem.maxY
//        
//        state.item[tempFoward].task.date = sourceDestination.task.date
//        state.item[tempFoward].minY = sourceDestination.minY
//        state.item[tempFoward].maxY = sourceDestination.maxY
        
        return .none
    }
}
