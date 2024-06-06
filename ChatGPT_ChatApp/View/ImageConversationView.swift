//
//  ImageConversationView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 6/2/24.
//

import SwiftUI
import OpenAI

struct ImageConversationView: View {
    
    @Environment(ImageViewModel.self) var imageVM
    @Environment(\.modelContext) var dbContext
    @State private var textfield: String = ""
    @State private var status: Model = .dall_e_2
    @State private var showingOptions = false
    var conversation: Conversation
    
    var body: some View {
        VStack {
            ScrollViewReader(content: { proxy in
                ScrollView {
                    VStack {
                        ForEach(conversation.messages.sorted(by: {$0.createdAt < $1.createdAt}), id: \.id) { message in
                            if message.role == .assistant {
                                HStack {
                                    VStack {
                                        Image(systemName: message.role == .assistant ? "desktopcomputer" : "person")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                        Text(message.role == .assistant ? "GPT" : "User")
                                            .frame(width: 40, height: 15)
                                        Spacer()
                                    }
                                    
                                    if let image = UIImage(data: message.content) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
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
                                        Spacer()
                                    }
                                    
                                    
                                }
                                .padding(.top, 5)
                            }
                        }

                        
                        Spacer()
                    }
                } //SCROLLVIEW
                .defaultScrollAnchor(.bottom)
            }) //SCROLLVIEWREADER
            
            
            Spacer()
            
            HStack {
                TextField("Ask a question...", text: $textfield)
                    .textFieldStyle(.roundedBorder)
                    .border(Color.gray, width: 0.5)
                
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    imageVM.disableButton = true
                    Task {
                        let message = Message(id: UUID().uuidString, role: .user, content: textfield.data(using: String.Encoding.utf8) ?? Data(), createdAt: Date())
                        conversation.messages.append(message)
                        await imageVM.getImage(conversation: conversation, prompt: textfield, model: status, n: 1)
                        textfield = ""

                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.title)
                        .rotationEffect(Angle(degrees: 45))
                }
                .buttonStyle(.borderless)
                .tint(.blue)
                .disabled(imageVM.disableButton || textfield.isEmpty)
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
        .modelSelectionDialog(showingOptions: $showingOptions, status: $status, state: .image)
        
    }
}
#Preview {
    NavigationStack {
        ImageConversationView(conversation: SampleData.conversation.first!)
            .modelContainer(previewRoutineContainer)
            .environment(ImageViewModel())
    }
}
