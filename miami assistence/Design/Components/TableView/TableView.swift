//
//  TableView.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 25/07/24.
//

import SwiftUI
import ComposableArchitecture

struct TableView<Content: View, Header: View, Footer: View, T: Reducer>: UIViewRepresentable {
    private let store: StoreOf<T>
    private let content: (IndexPath) -> Content
    private let headerSection: ((Int) -> Header)?
    private let footerSection: ((Int) -> Footer)?
    private let numberOfRows: Int
    private let numberOfSection: Int
    private let onScroll: ((CGPoint) -> Void)?
    private let onScrollBeginDragging: (() -> Void)?
    private let onScrollDidEndDragging: (() -> Void)?

    init(
        store: StoreOf<T>,
        numberOfRows: Int,
        numberOfSection: Int = 1,
        @ViewBuilder content: @escaping (IndexPath) -> Content,
        @ViewBuilder header: @escaping (Int) -> Header,
        @ViewBuilder footer: @escaping (Int) -> Footer,
        onScroll: ((CGPoint) -> Void)? = nil,
        onScrollBeginDragging: (() -> Void)? = nil,
        onScrollDidEndDragging: (() -> Void)? = nil
    ) where Footer == EmptyView {
        self.store = store
        self.numberOfRows = numberOfRows
        self.numberOfSection = numberOfSection
        self.content = content
        self.headerSection = header
        self.footerSection = footer
        self.onScroll = onScroll
        self.onScrollBeginDragging = onScrollBeginDragging
        self.onScrollDidEndDragging = onScrollDidEndDragging
    }
    
    init(
        store: StoreOf<T>,
        numberOfRows: Int,
        numberOfSection: Int = 1,
        @ViewBuilder content: @escaping (IndexPath) -> Content,
        @ViewBuilder header: @escaping (Int) -> Header,
        onScroll: ((CGPoint) -> Void)? = nil,
        onScrollBeginDragging: (() -> Void)? = nil,
        onScrollDidEndDragging: (() -> Void)? = nil
    ) where Footer == EmptyView {
        self.store = store
        self.numberOfRows = numberOfRows
        self.numberOfSection = numberOfSection
        self.content = content
        self.headerSection = header
        self.footerSection = nil
        self.onScroll = onScroll
        self.onScrollBeginDragging = onScrollBeginDragging
        self.onScrollDidEndDragging = onScrollDidEndDragging
    }
    
    init(
        store: StoreOf<T>,
        numberOfRows: Int,
        numberOfSection: Int = 1,
        @ViewBuilder content: @escaping (IndexPath) -> Content,
        @ViewBuilder footer: @escaping (Int) -> Footer,
        onScroll: ((CGPoint) -> Void)? = nil,
        onScrollBeginDragging: (() -> Void)? = nil,
        onScrollDidEndDragging: (() -> Void)? = nil
    ) where Header == EmptyView {
        self.store = store
        self.numberOfRows = numberOfRows
        self.numberOfSection = numberOfSection
        self.content = content
        self.headerSection = nil
        self.footerSection = footer
        self.onScroll = onScroll
        self.onScrollBeginDragging = onScrollBeginDragging
        self.onScrollDidEndDragging = onScrollDidEndDragging
    }
    
    init(
        store: StoreOf<T>,
        numberOfRows: Int,
        numberOfSection: Int = 1,
        @ViewBuilder content: @escaping (IndexPath) -> Content,
        onScroll: ((CGPoint) -> Void)? = nil,
        onScrollBeginDragging: (() -> Void)? = nil,
        onScrollDidEndDragging: (() -> Void)? = nil
    ) where Header == EmptyView,
            Footer == EmptyView {
        self.store = store
        self.numberOfRows = numberOfRows
        self.numberOfSection = numberOfSection
        self.content = content
        self.headerSection = nil
        self.footerSection = nil
        self.onScroll = onScroll
        self.onScrollBeginDragging = onScrollBeginDragging
        self.onScrollDidEndDragging = onScrollDidEndDragging
    }
    
    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
        var parent: TableView

        init(_ parent: TableView) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.numberOfRows
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            parent.numberOfSection
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
            let cell = UITableViewCell()
            
            cell.contentConfiguration = UIHostingConfiguration {
                parent.content(indexPath)
            }

            return cell
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            if let sectionHeader = parent.headerSection?(section) {
                let view = UIView()
                let headerSection = UIHostingController(rootView: sectionHeader)

                let headerSectionView = headerSection.view!
                headerSectionView.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(headerSectionView)
                
                // 3
                // Create and activate the constraints for the swiftui's view.
                NSLayoutConstraint.activate([
                    headerSectionView.widthAnchor.constraint(equalToConstant: tableView.frame.width),
                    headerSectionView.heightAnchor.constraint(equalToConstant: 50),
                    headerSectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    headerSectionView.topAnchor.constraint(equalTo: view.topAnchor),
                    headerSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    headerSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
                
                return view
            }
            
            return nil
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            if let footerView = parent.footerSection?(section) {
                let view = UIView()
                let footerSection = UIHostingController(rootView: footerView)

                let headerSectionView = footerSection.view!
                headerSectionView.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(headerSectionView)
                
                // 3
                // Create and activate the constraints for the swiftui's view.
                NSLayoutConstraint.activate([
                    headerSectionView.widthAnchor.constraint(equalToConstant: tableView.frame.width),
                    headerSectionView.heightAnchor.constraint(equalToConstant: 50),
                    headerSectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    headerSectionView.topAnchor.constraint(equalTo: view.topAnchor),
                    headerSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    headerSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
                return view
            }
            
            return nil
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if parent.headerSection != nil {
                return 50
            } else {
                return 0
            }
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            if parent.footerSection != nil {
                return 50
            } else {
                return 0
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.onScroll?(scrollView.contentOffset)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            parent.onScrollBeginDragging?()
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            parent.onScrollDidEndDragging?()
        }
    }
}
