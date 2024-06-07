//
//  ConversationView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/25/24.
//

import SwiftUI
import OpenAI

enum ChatOption {
    case text
    case speach
    case image
}

struct ConversationView: View {
    
    @Environment(ChatGPT.self) var chat
    @Environment(\.modelContext) var dbContext
    @State private var textfield: String = ""
    @State private var status: Model = .gpt3_5Turbo
    @State private var showingOptions = false
    
    var conversation: Conversation
    
    func sortedMessage(messages: [Message]) -> [Message] {
        return messages.sorted(by: {$0.createdAt < $1.createdAt})
    }
    
    var body: some View {
        VStack {
            ScrollViewReader(content: { proxy in
                    ScrollView {
                        ForEach(sortedMessage(messages: conversation.messages), id: \.self) { message in
                            if message.role == .assistant {
                                HStack {
                                    VStack {
                                        Image(systemName: message.role == .assistant ? "desktopcomputer" : "person")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                        Text(message.role == .assistant ? "GPT" : "User")
                                            .frame(width: 40, height: 15)
                                    }
                                    
                                    Text(String(data: message.content, encoding: String.Encoding.utf8) ?? "no value")
                                        .padding(8)
                                        .textFieldStyle(.roundedBorder)
                                        .background(.gptMessage)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .contextMenu {
                                            Button {
                                                UIPasteboard.general.string = String(data: message.content, encoding: String.Encoding.utf8)
                                            } label: {
                                                Text("Copy")
                                                Image(systemName: "doc.on.doc")
                                            }
                                        }
                                    
                                    
                                    Spacer()
                                }
                                .padding(.top, 5)
                            } else {
                                HStack {
                                    
                                    Spacer()
                                    
                                    Text(String(data: message.content, encoding: String.Encoding.utf8) ?? "no value")
                                        .padding(8)
                                        .textFieldStyle(.roundedBorder)
                                        .background(Color("MyMessageColor"))
                                        .foregroundStyle(.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))

                                    
                                    VStack {
                                        Image(systemName: message.role == .assistant ? "desktopcomputer" : "person")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                        Text(message.role == .assistant ? "GPT" : "User")
                                            .frame(width: 40, height: 15)
                                            .contextMenu {
                                                Button {
                                                    UIPasteboard.general.string = String(data: message.content, encoding: String.Encoding.utf8)
                                                } label: {
                                                    Text("Copy")
                                                    Image(systemName: "doc.on.doc")
                                                }
                                            }
                                    }
                                    
                                    
                                }
                                .padding(.top, 5)
                            }

                        } //FOREACH
                        
                        Spacer()

                    } //SCROLLVIEW
                    .onChange(of: sortedMessage(messages: conversation.messages)) { oldValue, newValue in
                        proxy.scrollTo(newValue[newValue.endIndex - 1])
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { notification in
                        withAnimation() {
                            let value = sortedMessage(messages: conversation.messages)
                            if !value.isEmpty {   
                                proxy.scrollTo(value[value.endIndex - 1], anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        let value = sortedMessage(messages: conversation.messages)
                        if !value.isEmpty {
                            proxy.scrollTo(value[value.endIndex - 1], anchor: .bottom)
                        }
                    }

            }) //SCROLLVIEWREADER
            
            
            Spacer()
            
            HStack {
                TextField("Ask a question...", text: $textfield)
                    .textFieldStyle(.roundedBorder)
                    .border(Color.gray, width: 0.5)
                
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    chat.disableButton = true
                    Task {
                        let message = Message(id: UUID().uuidString, role: .user, content: textfield.data(using: String.Encoding.utf8) ?? Data(), createdAt: Date())
                        conversation.messages.append(message)
                        textfield = ""
                        await chat.sendMessage(message, conversation: conversation, model: status, modelContext: dbContext)
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.title)
                        .rotationEffect(Angle(degrees: 45))
                }
                .buttonStyle(.borderless)
                .tint(.blue)
                .disabled(chat.disableButton || textfield.isEmpty)
            }
            .padding()
        }
        .toolbar(.hidden, for: .tabBar)
        .onTapGesture {
            hideKeyboard()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingOptions = true
                } label: {
                    Image(systemName: "cpu")
                        .foregroundStyle(Color.green.gradient)
                    
                }
            }
        }
        .modelSelectionDialog(showingOptions: $showingOptions, status: $status, state: .text)
    }
}


struct ConversationScreen: View {
    var body: some View {
        ConversationView(conversation: .init(id: "", category: 0, created: Date()))
            .modelContainer(previewRoutineContainer)
            .environment(ChatGPT())
    }
}

#Preview { @MainActor in
    NavigationStack {
        ConversationView(conversation: SampleData.conversation.first!)
            .modelContainer(previewRoutineContainer)
            .environment(ChatGPT())
    }
}
