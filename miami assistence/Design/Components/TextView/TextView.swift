//
//  TextView.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 19/10/23.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    var text: String
    var focusTrigger: Bool
    var processorText: NSAttributedString? = nil

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        
        if let superview = uiView.superview {
            NSLayoutConstraint.activate([
                uiView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                uiView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                uiView.topAnchor.constraint(equalTo: superview.topAnchor),
                uiView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UITextViewDelegate {
        
        // MARK: - Toolbar actions
        
        @objc func boldText() {
            // Implementar ação para texto em negrito
        }
        
        @objc func italicText() {
            // Implementar ação para texto em itálico
        }
        
        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        
        // MARK: - UITextViewDelegate

        func textViewDidChange(_ textView: UITextView) { }
        
        func textViewDidBeginEditing(_ textView: UITextView) { }
        
        func textViewDidEndEditing(_ textView: UITextView) { }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { true }
        
        func textViewDidChangeSelection(_ textView: UITextView) { }
    }
}
