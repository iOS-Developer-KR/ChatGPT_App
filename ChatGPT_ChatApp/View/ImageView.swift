//
//  ImageView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/26/24.
//

import SwiftUI
import SwiftData

struct ImageView: View {
    @Environment(ImageViewModel.self) var chat
    @State private var textfield: String = ""
    @State private var newConversation: Bool = false
    @Environment(\.modelContext) var dbContext
    @Query var conversations: [Conversation]
    
    init() {
        let temp = Category.image.rawValue
        
        let filter = #Predicate<Conversation> { value in
            value.category == 1
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
                ImageConversationView(conversation: value)
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
//struct ImageView: View {
//    @Environment(ChatGPT.self) var chat
//    @State private var textfield: String = ""
//    @State private var url: String = ""
//    @State var progress: Bool = false
//    var body: some View {
//        VStack {
//            TextField("Please enter...", text: $textfield)
//            Button(action: {
//                progress.toggle()
//                Task {
//                    await chat.getImage(prompt: textfield, n: 1, completion: { text in
//                        url = text
//                        progress.toggle()
//                    })
//                }
//            }, label: {
//                Text("Create")
//            })
//            AsyncImage(url: URL(string: url)) { result in
//                result
//                    .resizable()
//                    .scaledToFit()
//            } placeholder: {
//                if progress {
//                    ProgressView()
//                }
//            }
//
//
//            Spacer()
//        }.padding()
//    }
//}

#Preview {
    ImageView()
        .environment(ImageViewModel())
}
