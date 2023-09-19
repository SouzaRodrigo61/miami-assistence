//
//  Home+Feature.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 26/07/23.
//

import SwiftUI
import ComposableArchitecture

extension Home {
    struct Feature: Reducer {
        struct State: Equatable {
            var taskCalendar: TaskCalendar.Feature.State
            var bottomSheet: BottomSheet.Feature.State?
            var taskCreate: TaskCreate.Feature.State?
            
            var destination: StackState<Destination.State>
            @PresentationState var schedule: Schedule.Feature.State?
            
            var contentTask: Task.Model?
            
            /// Custom Matched Geometry Animation
            var forcePadding: Bool = false
            
            
            var currentIndex: Int = 1
        }
        
        enum Action: Equatable {
            
            /// Components Stores
            case bottomSheet(BottomSheet.Feature.Action)
            case taskCreate(TaskCreate.Feature.Action)
            case taskCalendar(TaskCalendar.Feature.Action)
            
            /// Local Actions
            case matcheAnimationRemoved
            
            /// Navigation Stores
            case destination(StackAction<Destination.State, Destination.Action>)
            case schedule(PresentationAction<Schedule.Feature.Action>)
        }
        
        var body: some Reducer<State, Action> {
            Reduce(self.core)
                .ifLet(\.bottomSheet, action: /Action.bottomSheet) {
                    BottomSheet.Feature()
                }
                .ifLet(\.taskCreate, action: /Action.taskCreate) {
                    TaskCreate.Feature()
                }
                .ifLet(\.$schedule, action: /Action.schedule) {
                    Schedule.Feature()
                }
                .forEach(\.destination, action: /Action.destination) {
                    Destination()
                }
        }
        
        private func core(into state: inout State, action: Action) -> Effect<Action> {
            switch action {
            case .bottomSheet(.addButtonTapped):
                let date = state.taskCalendar.weekSlider[state.taskCalendar.currentIndex]
                state.taskCreate = .init(date: date.date)
                
                state.bottomSheet?.collapse = false
                
                guard state.taskCalendar.header != nil else { return .none }
                state.taskCalendar.header?.isScroll = false
                
                return .none
            case .taskCalendar(.task(.showTaskCreate)):
                let date = state.taskCalendar.weekSlider[state.taskCalendar.currentIndex]
                state.taskCreate = .init(date: date.date)
                
                state.bottomSheet?.collapse = false
                
                guard state.taskCalendar.header != nil else { return .none }
                state.taskCalendar.header?.isScroll = false
                
                return .none
            case .taskCreate(.createTaskTapped):
                guard let content = state.taskCreate else { return .none }
                
                guard state.taskCalendar.task != nil else { return .none }
                guard let count = state.taskCalendar.task?.item.count else { return .none }
                state.taskCalendar.task?.empty = nil
                
                state.taskCalendar.task?.item.append(.init(task: .init(title: content.title, date: content.date, startedHour: .now, duration: Double(content.activityDuration.rawValue), color: content.color, isAlert: false, isRepeted: false, position: (count + 1), createdAt: .now, updatedAt: .now, tag: [], note: [])))
                
                state.taskCreate = nil
                
                return .none
            case .taskCreate(.closeTapped):
                state.taskCreate = nil
                
                guard state.taskCalendar.header != nil else { return .none }
                state.taskCalendar.header?.isScroll = false
                
                return .none
            case let .taskCalendar(.task(.item(_, .contentTapped(task)))):
                state.destination.append(.note(.init(task: task)))
                state.contentTask = task
                
                return .none
                
            case .taskCalendar(.header(.today(.buttonTapped))):
                state.schedule = .init()
                
                return .none
                
            case .destination(.element(id: _, action: .note(.closeTapped))):
                state.forcePadding = true
                return .run { send in
                    try! await SwiftUI.Task.sleep(for: .seconds(0.04))
                    await send(.matcheAnimationRemoved, animation: .smooth)
                }
                
            case let .taskCalendar(.previousDay(day)):

                state.taskCalendar.weekSlider.insert(day.createPreviousDay(), at: 0)
                state.taskCalendar.weekSlider.removeLast()
                
                state.taskCalendar.currentIndex = 1
                state.taskCalendar.createDay = false
                
                return .none
                
            case let .taskCalendar(.nextDay(day)):
                
                state.taskCalendar.weekSlider.append(day.createNextDay())
                state.taskCalendar.weekSlider.removeFirst()
                
                state.taskCalendar.currentIndex = 1
                state.taskCalendar.createDay = false
                
                return .none
                
            case let .taskCalendar(.tabSelected(index)):
                state.taskCalendar.currentIndex = index
                if index == 0 || index == (state.taskCalendar.weekSlider.count - 1) {
                    state.taskCalendar.createDay = true
                }
                
                let currentDate = state.taskCalendar.weekSlider[index].date
                
                state.taskCalendar.task = .init(empty: .init(.init(currentDate: currentDate)))
                state.taskCalendar.header = .init(
                    today: .init(
                        week: currentDate.validateIsToday(),
                        weekCompleted: currentDate.week()
                    )
                )
                
                return .none
                
                
            case .matcheAnimationRemoved:
                state.forcePadding = false
                state.contentTask = nil
                
                return .none
            
            case .taskCalendar(.onAppear):
                dump(state.taskCalendar.weekSlider)
                
                return .none
            default:
                return .none
            }
        }
    }
}
