//
//  ContentView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/25/24.
//

import SwiftUI
import OpenAI
import SwiftData



struct MainView: View {
    
    @Environment(ChatGPT.self) var chat
    @State private var textfield: String = ""
    @State private var newConversation: Bool = false
    @Environment(\.modelContext) var dbContext
//    @Query(filter: #Predicate<Conversation> { $0.category == Category.text.rawValue }, sort: \.created, order: .reverse) 
    @Query var conversations: [Conversation]

    init() {
        let temp = Category.text // 이렇게 변수로 만들어서 사용해야지 바로 사용하면 Key path cannot refer to enum case 에러 발생한다
        
        let filter = #Predicate<Conversation> { value in
            value.category == 0
        }
        _conversations = Query(filter: filter, sort: \.created, order: .reverse)
    }
    
    func truncatedText(_ text: String, length: Int) -> String {
        if text.count > length {
            let index = text.index(text.startIndex, offsetBy: length)
            return String(text[..<index]) + "..."
        } else {
            return text
        }
    }
    
    func returnFirstMessage(messages: [Message]) -> String {
        let message = messages.sorted { m1, m2 in
            m1.createdAt < m2.createdAt
        }.first
        if let message = message {
            return truncatedText(String(data: message.content, encoding: String.Encoding.utf8) ?? "no value", length: 20)
        } else {
            return "대화 내용이 없습니다"
        }
    }
    
    var body: some View {
        
        NavigationStack {
                
                VStack {
                    List(conversations, id: \.id) { conversation in
                        NavigationLink(value: conversation) {
                            HStack {
                                VStack {
                                    HStack {
                                        Text(returnFirstMessage(messages: conversation.messages))
                                            .foregroundStyle(Color.white)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(dateformat.string(from: conversation.created))")
                                            .font(.caption)
                                            .foregroundStyle(Color.gray.opacity(0.8))
                                        Spacer()
                                    }
                                    
                                }
                                Spacer()

                            }
                            .swipeActions {
                                
                                Button(role: .destructive) {
                                    chat.deleteConversation(conversation.id, modelContext: dbContext)
                                } label: {
                                    VStack {
                                        Label("Delete", systemImage: "trash")
                                            .background(Color.red)
                                            .foregroundStyle(Color.red)
                                    }
                                }
                                .foregroundStyle(Color.red)
                            }
                        }
                        
                        .padding()
                    }

                    Spacer()
                }
                .navigationTitle("Chat List")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Conversation.self) { value in
                    ConversationView(conversation: value)
                        .environment(ChatGPT())
                        .modelContainer(previewRoutineContainer)
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            
                            Spacer()
                            
                            Button(action: {
                                chat.createConversation(modelContext: dbContext)
                            }, label: {
                                Image(systemName: "plus.circle")
                            })
                        }
                    }
                }//TOOLBAR
        } //NAVIGATION
    }
}

struct MainViewScreen: View {
    
    var body: some View {
        NavigationStack {
            MainView()
                .modelContainer(previewRoutineContainer)
                .environment(ChatGPT())
        }
    }
}

#Preview { @MainActor in
    MainViewScreen()
    
}
