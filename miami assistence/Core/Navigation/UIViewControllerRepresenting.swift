//
//  UIViewControllerRepreseting.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 25/07/24.
//

import SwiftUI

struct UIViewControllerRepresenting: UIViewControllerRepresentable {
    let base: UIViewController
    init(base: () -> UIViewController) {
        self.base = base()
    }
    
    func makeUIViewController(context: Context) -> some UIViewController { base }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}


struct UIViewRepresenting: UIViewRepresentable {
    let base: UIView
    init(base: () -> UIView) {
        self.base = base()
    }
    
    func makeUIView(context: Context) -> some UIView { base }
    func updateUIView(_ uiView: UIViewType, context: Context) { }
}
