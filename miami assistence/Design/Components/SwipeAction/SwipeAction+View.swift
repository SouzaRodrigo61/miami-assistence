//
//  SwipeAction+View.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 01/09/23.
//

import SwiftUI

extension SwipeAction {
    struct View<Content: SwiftUI.View>: SwiftUI.View {
        
        var cornerRadius: CGFloat = 0
        var direction: Direction = .trailing
        
        @ViewBuilder var content: Content
        @ActionBuilder var actions: [Action]
        
        let viewID = UUID()
        
        @State private var isEnabled: Bool = true
        @State private var scrollOffset: CGFloat = .zero
        
        var body: some SwiftUI.View {
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        content
                        /// To Take Full Available Space
                            .containerRelativeFrame(.horizontal)
                            .background(.white)
                            .background {
                                if let firstAction = actions.first {
                                    Rectangle()
                                        .foregroundStyle(firstAction.tint)
                                        .opacity(scrollOffset == .zero ? 0 : 1)
                                }
                            }
                            .id(viewID)
                            .transition(.identity)
                            .overlay {
                                GeometryReader {
                                    let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                                    
                                    Color.clear
                                        .preference(key: OffsetKey.self, value: minX)
                                        .onPreferenceChange(OffsetKey.self) { value in
                                            scrollOffset = value
                                        }
                                }
                            }
                        
                        ActionButtons {
                            withAnimation(.snappy) {
                                scrollProxy.scrollTo(viewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
                            }
                        }
                    }
                    .scrollTargetLayout()
                    .visualEffect { content, geo in
                        content.offset(x: scrollOffset(geo))
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .background {
                    if let lastAction = actions.last {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
                            .foregroundStyle(lastAction.tint)
                            .opacity(scrollOffset == .zero ? 0 : 1)
                    }
                }
                .clipShape(.rect(cornerRadius: cornerRadius))
            }
            .allowsHitTesting(isEnabled)
            .transition(CustomTransaction())
        }
        
        /// Action Buttons
        @ViewBuilder
        func ActionButtons(resetPosition: @escaping () -> ()) -> some SwiftUI.View {
            // MARK: Each Button Will Have 100 Width
            Rectangle()
                .fill(.clear)
                .frame(width: CGFloat(actions.count) * 100)
                .overlay(alignment: direction.alignment) {
                    HStack(spacing: 0) {
                        ForEach(actions) { button in
                            Button {
                                _Concurrency.Task {
                                    resetPosition()
                                    try? await _Concurrency.Task.sleep(for: .seconds(0.25))
                                    button.action()
                                }
                            } label: {
                                Image(systemName: button.icon)
                                    .font(button.iconFont)
                                    .foregroundStyle(button.iconColor)
                                    .frame(width: 100)
                                    .frame(maxHeight: .infinity)
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .background(button.tint)
                        }
                    }
                }
        }
        
        /// Block scrolling
        func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
            let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
            return direction == .trailing ? (minX > 0 ? -minX : 0) : (minX < 0 ? -minX : 0)
        }
        
    }
    
    struct Action: Identifiable {
        private(set) var id: UUID = .init()
        var tint: Color
        var icon: String
        var iconFont: Font = .title
        var iconColor: Color = .white
        var isEnabled: Bool = true
        var action: () -> ()
    }
    
    @resultBuilder
    struct ActionBuilder {
        static func buildBlock(_ components: Action...) -> [Action] {
            return components
        }
    }
    
    enum Direction {
        case leading
        case trailing
        
        var alignment: Alignment {
            switch self {
            case .leading: return .leading
            case .trailing: return .trailing
            }
        }
    }
}


/// Custom Transition
struct CustomTransaction: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content.mask {
            GeometryReader {
                let size = $0.size
                
                Rectangle()
                    .offset(y: phase == .identity ? 0 : -size.height)
            }
            .containerRelativeFrame(.horizontal)
        }
    }
}
