//
//  ViewExtension.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/27/24.
//

import Foundation
import SwiftUI
import OpenAI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func modelSelectionDialog(showingOptions: Binding<Bool>, status: Binding<Model>, state: Category) -> some View {
        self.confirmationDialog("Select GPT Model", isPresented: showingOptions, titleVisibility: .visible) {
            switch state {
            case .text:
                Button {
                    status.wrappedValue = .dall_e_2
                } label: {
                    Text(Model.dall_e_2)
                }
                Button {
                    status.wrappedValue = .dall_e_3
                } label: {
                    Text(Model.dall_e_3)
                }
            case .image:
                Button {
                    status.wrappedValue = .gpt3_5Turbo
                } label: {
                    Text(Model.gpt3_5Turbo)
                }
                Button {
                    status.wrappedValue = .gpt4
                } label: {
                    Text(Model.gpt4)
                }
                Button {
                    status.wrappedValue = .gpt4_o
                } label: {
                    Text(Model.gpt4_o)
                }
            }
        }
    }
}
