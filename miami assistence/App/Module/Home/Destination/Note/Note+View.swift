//
//  TaskDetails+View.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 20/08/23.
//

import ComposableArchitecture
import SwiftUI
import UIKit
import Combine

let cellIdentifier = "cell"

extension Note {
    struct View: SwiftUI.View {
        let store: StoreOf<Feature>
        
        var body: some SwiftUI.View {
            WithViewStore(store, observe: \.note) { viewStore in
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEachStore(store.scope(state: \.item, action: \.item)) {store in
//                                NoteItem.View(store: store)
                                VStack {
                                    Text("testes")
                                }
                            }
                        }
                        .padding(8)
                    }
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                }
                .scrollDismissesKeyboard(.immediately)
                .coordinateSpace(name: "FORMSCROLL")
                .accessibilityLabel("")
                .contentMargins(12, for: .scrollContent)
                .listRowSpacing(0)
                .listSectionSpacing(4)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .listSectionSeparator(.hidden)
                .background(.regularMaterial, in: .rect(cornerRadius: 12))
                .padding(8)
                .toolbarBackground(.visible, for: .navigationBar)
                .onTapGesture(count: 2) {
                    send(.addBlockTapped, animation: .linear)
                }
            }
        }
    }
}

extension Note {
    @ViewAction(for: Feature.self)
    final class ViewController: UIViewController {
        var store: StoreOf<Feature>
        var cancellables: Set<AnyCancellable> = []
        
        var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
        
        var collectionView: UICollectionView? = {
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: UICollectionViewCompositionalLayout.list(
                    using: UICollectionLayoutListConfiguration(appearance: .plain)
                )
            )
            collectionView.backgroundColor = .white
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            return collectionView
        }()
        
        init(store: StoreOf<Feature>) {
            self.store = store
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupCollectionView()
            setupTapGesture()
            
            guard let collectionView else { return }
            
            let cellRegistration = UICollectionView.CellRegistration<NoteItem.BlockCell, Item> { [weak self] cell, indexPath, item in
                guard let self else { return }
                
                configure(cell: cell, indexPath: indexPath, item: item)
            }
            
            self.dataSource = UICollectionViewDiffableDataSource<Section, Item>(
                collectionView: collectionView
            ) { collectionView, indexPath, item in
                collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
            }
            
            observe { [weak self] in
                guard let self else { return }
                dataSource.apply(
                    NSDiffableDataSourceSnapshot(model: store.blocks),
                    animatingDifferences: true
                )
            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }
        
        private func setupCollectionView() {
            guard let collectionView else { return }
            
            collectionView.delegate = self

            view.addSubview(collectionView)
            
            // Configure constraints para tableView
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
        private func setupTapGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapGesture.numberOfTapsRequired = 2
            view.addGestureRecognizer(tapGesture)
        }

        @objc private func handleTap() {
            send(.addBlockTapped, animation: .linear)
        }
    }
}

extension Note.ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dump(indexPath, name: "IndexPath")
    }
    
    // Implementação do método para dimensionar dinamicamente as células
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UICollectionViewFlowLayout.automaticSize
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        customDump("scrollViewWillBeginDragging")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        customDump("scrollViewDidEndDecelerating")
    }
}

extension Note.ViewController {
    enum Section {
        case top
    }
    
    enum Item: Hashable {
        case content(UUID)
    }
    
    private func configure(
        cell: NoteItem.BlockCell,
        indexPath: IndexPath,
        item: Item
    ) {

        var cellStore: Store<NoteItem.Feature.State, NoteItem.Feature.Action>?
        var text: String?
        var att: NSAttributedString?
        
        defer {
            if indexPath.row == 0, let textView = cell.textView, textView.canBecomeFocused {
                cell.textView?.becomeFirstResponder()
            }
            
            cell.tag = indexPath.row
            cell.delegate = delegate()
            cell.textView?.text = text
            cell.textView?.attributedText = att
            cell.store = cellStore
            cell.initialize()
        }
        
        switch item {
        case let .content(id):
            store.scope(state: \.blocks[id: id], action: \.blocks[id: id]).ifLet(
                then: { childStore in
                    text = childStore.state.block.content
                    att = childStore.state.block.contentCache
                    
                    cellStore = childStore
                }
              )
              .store(in: &cancellables)
        }
    }
}

extension Note.ViewController {
    
    // MARK: - BlockCellDelegate ( Protocol Witness )
    func delegate() -> NoteItem.BlockCellDelegate<NoteItem.BlockCell> {
        .init { cell, id in
            
        } didPickerToScroll: { cell, id in
            
        } didTextViewDidBeginEditing: { cell, id in
            
        } didTextViewDidEndEditing: { [weak self] cell, id in
            guard let self, let collectionView else { return }
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates(nil, completion: nil)
            }
        } didTextViewDidChange: { cell, id in
            
        } didTextViewShouldChangeEnter: { [weak self] cell, id in
            guard let self, let collectionView, cell.store != nil else { return }
            
            let nextRow = cell.tag + 1
            
            // Inserir novo parágrafo no documento
            send(.addBlockTapped)
            
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates(nil) { _ in
                    // Tentativa de focar na nova célula
                    if let newRowCell = collectionView.cellForItem(at: IndexPath(row: nextRow, section: 0)) as? NoteItem.BlockCell {
                        
                        newRowCell.textView?.becomeFirstResponder()
                    }
                }

            }
            
        } didTextViewShouldChangeIsEmpty: { [weak self] cell, id in
            guard let self, let collectionView else { return }
            let previousRow = max(cell.tag - 1, 0)
            
            if let previousRowCell = collectionView.cellForItem(at: IndexPath(row: previousRow, section: 0)) as? NoteItem.BlockCell {
                
                previousRowCell.textView?.becomeFirstResponder()
                
                self.send(.removeBlockTapped(id))
            }
            
        } didTextViewChangeSelection: { cell, id in
            
        }
    }
}

extension NSDiffableDataSourceSnapshot<Note.ViewController.Section, Note.ViewController.Item> {
    
    @MainActor
    init(model: IdentifiedArrayOf<NoteItem.Feature.State>) {
        self.init()
        
        appendSections([.top])
        appendItems(
            model.map { .content($0.id) },
            toSection: .top
        )
        
    }
}

