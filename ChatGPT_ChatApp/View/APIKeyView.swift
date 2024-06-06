//
//  APIKeyView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 6/1/24.
//

import SwiftUI
import OpenAI

struct APIKeyView: View {
    @Environment(KeyChain.self) var keychain
    @State private var text = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("You must enter an API Key issued by OpenAI to use the app. If you do not use it frequently, you can save costs by directly paying for the usage you want with ChatGPT rather than using a subscription plan to use ChatGPT.")
                    .padding()
                
                HStack {
                    VStack {
                        Text("Don't have an API key?")
                            .bold()
                        
                        Link("Click here to make API Key", destination: URL(string: "https://platform.openai.com/account/api-keys")!)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                
                TextField("Input your API Key", text: $text)
                    .padding(8)
                    .textFieldStyle(.roundedBorder)
                    .background(Color("MyMessageColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                
                Button {
                    Task {
                        do {
                            let openAI = OpenAI(apiToken: text)
                            let query = ChatQuery(messages: [.init(role: .user, content: "Token Test")!], model: .gpt3_5Turbo)
                            let _ = try await openAI.chats(query: query)
                            try KeyChain.shared.saveToken(token: text)
                            keychain.exist = true
                            print("성공")
                        } catch {
                            print(error.localizedDescription)
                            showAlert = true
                        }
                    }
                } label: {
                    Text("Enter")
                        .padding(10)
                }
                .background(Color.gray.opacity(0.4))
                .cornerRadius(20)
                
                Spacer()
            }
            .navigationTitle("OpenAI API Key")
            .alert("API Key Validation failed", isPresented: $showAlert) {
            } message: {
                Text("Please check your API Key again")
            }
        } // NAVIGATIONSTACK
        .onAppear {
            keychain.getToken()
        }
    }
}

#Preview {
    APIKeyView()
        .environment(KeyChain())
}
