//
//  NoteItem+View.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 25/09/23.
//

import ComposableArchitecture
import SwiftUI
import UIKit
import Markdown
import SwiftUIIntrospect

extension NoteItem {
    struct View: SwiftUI.View {
        var store: StoreOf<Feature>
        
        @ObservedObject var customTextViewDelegate = CustomTextViewDelegate()
        
        var body: some SwiftUI.View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                TextEditor(text: .constant(viewStore.state.id.description))
                    .introspect(.textEditor, on: .iOS(.v17, .v18)) { textView in
                        textView.delegate = customTextViewDelegate
                    }
                    
            }
        }
    }
    
    class CustomTextViewDelegate: NSObject, ObservableObject, UITextViewDelegate {
        @Published private(set) var isEditing: Bool = false
        
        var textView: UITextView? {
            didSet {
                if delegate == nil, let delegate = textView?.delegate {
                    textView?.delegate = self
                    self.delegate = delegate
                }
            }
        }
        
        private weak var delegate: UITextViewDelegate?
        
        func textViewDidChange(_ textView: UITextView) {
            customDump(textView.text)
        }
    }
}

extension NoteItem {
    final class BlockCell: UICollectionViewCell {
        static let reuse = "BlockCell"
        
        // MARK: - Properties
        
        var store: StoreOf<Feature>?
        var contentText: String = ""
        
        var delegate: BlockCellDelegate<BlockCell>?
        
        // MARK: - Properties UI
        
        var stackView: UIStackView? = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.spacing = 10
            return stackView
        }()
        
        var textView: UITextView? = {
            let textView = UITextView()
            textView.font = .systemFont(ofSize: 16)
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.backgroundColor = .clear
            textView.isEditable = true
            textView.isScrollEnabled = false
            
            textView.setContentHuggingPriority(.defaultLow, for: .vertical)
            textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            return textView
        }()
        
        var leadingIcon: UIImageView? = {
            let actionIcon = UIImageView()
            actionIcon.isHidden = true
            actionIcon.isUserInteractionEnabled = true
            actionIcon.tintColor = .blue
            actionIcon.contentMode = .scaleAspectFit
            actionIcon.translatesAutoresizingMaskIntoConstraints = false
            actionIcon.image = UIImage(systemName: "text.word.spacing")
            return actionIcon
        }()
        
        var trailingIcon: UIImageView? = {
            let actionIcon = UIImageView()
            actionIcon.isHidden = true
            actionIcon.isUserInteractionEnabled = true
            actionIcon.tintColor = .blue
            actionIcon.contentMode = .scaleAspectFit
            actionIcon.translatesAutoresizingMaskIntoConstraints = false
            actionIcon.image = UIImage(systemName: "text.word.spacing")
            return actionIcon
        }()
        
        // MARK: - Life Cycle
        func initialize() {
            setupStackView()
            setupTextView()
            configure()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            contentText = ""
            
            guard let textView else { return }
            
            textView.text = ""
            textView.attributedText = nil
            
        }
        
        // MARK: - Setup UI
        
        private func setupStackView() {
            guard let stackView else { return }
            
            contentView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }
        
        private func setupTextView() {
            guard let textView, let stackView else { return }
            
            stackView.addArrangedSubview(textView)
            textView.text = contentText
            textView.delegate = self
        }
        
        // MARK: - Setup Content
        private func configure() {
            guard let textView, let store else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                observe {
                    if let att = store.state.block.contentCache {
                        textView.attributedText = att
                    } else {
                        textView.text = store.state.block.content
                    }
                }
            }
        }
    }
}

extension NoteItem.BlockCell {
    private func updateCellHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            guard let collectionView = superview as? UICollectionView else { return }
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates(nil, completion: nil)
            }
        }
    }
}

extension NoteItem.BlockCell {
    
    func setupParser(with text: String, completion: @escaping (NSAttributedString) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var markdownParser = MarkdownAttributedStringParser()
            let document = Markdown.Document(parsing: text)
            let parsedAttributedString = markdownParser.attributedString(from: document)

            DispatchQueue.main.async {
                completion(parsedAttributedString)
            }
        }
    }
}


extension NoteItem.BlockCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let store else { return }
        
        updateCellHeight()
        
        contentText = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let store else { return }
        guard let delegate = delegate else { return }
        delegate.didTextViewDidBeginEditing(self, store.state.id)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let store else { return }
        
        setupParser(with: contentText) { attributedString in
            store.send(.blockContent(textView.text, attributedString))
        }
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let store else { return false }
        guard let delegate = delegate else { return false }
        
        if text == "\n" {
            delegate.didTextViewShouldChangeEnter(self, store.state.id)
            return false
        } else if text.isEmpty {
            
            let nsText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            nsText.replaceCharacters(in: range, with: text)

            // Verifica se após a alteração, o texto é vazio e não contém attachments
            let isEmpty = nsText.length == 0 || (nsText.length == 1 && nsText.attribute(.attachment, at: 0, effectiveRange: nil) != nil)
            
            if isEmpty {
                contentText = ""
                delegate.didTextViewShouldChangeIsEmpty(self, store.state.id)
            }
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let store else { return }
        guard let delegate = delegate else { return }
        delegate.didTextViewChangeSelection(self, store.state.id)
    }
}


extension NoteItem {
    struct BlockCellDelegate<Cell: BlockCell> {
        /// Tap Button
        let didTapButton: (Cell, UUID) -> Void
        
        /// Picker Image
        let didPickerToScroll: (Cell, UUID) -> Void
        
        /// TextEditor Basic
        let didTextViewDidBeginEditing: (Cell, UUID) -> Void
        let didTextViewDidEndEditing: (Cell, UUID) -> Void
        let didTextViewDidChange: (Cell, UUID) -> Void
        
        /// TextEditor Should Text Change
        let didTextViewShouldChangeEnter: (Cell, UUID) -> Void
        let didTextViewShouldChangeIsEmpty: (Cell, UUID) -> Void
        
        /// TextEditor Should Text Selected
        let didTextViewChangeSelection: (Cell, UUID) -> Void
        
        /// On Gesture
    }
}
