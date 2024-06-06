//
//  ChatGPT.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/25/24.
//

import Foundation
import OpenAI
import SwiftUI
import SwiftData
import Combine


@Observable
public final class ChatGPT {
    let openAIClient = OpenAI(apiToken: "sk-proj-ovvWWx2QACLabNcJcdv5T3BlbkFJilzZz5OV79BWAS7uL2Qf")
    
    var conversations: [Conversation] = []
    var conversationErrors: [Conversation.ID: Error] = [:]
    var selectedConversationID: Conversation.ID?
    
    var disableButton: Bool = false
    
    var captureURL: URL { // 캡쳐한 url을 저장
        (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("recording.m4a", conformingTo: .audio))!
    }
    
    
    
    func selectedConversation() -> Conversation? {
        selectedConversationID.flatMap { id in
            conversations.first { $0.id == id }
        }
    }
    
    // MARK: - Events
    func createConversation(modelContext: ModelContext) {
        let conversation = Conversation(id: UUID().uuidString, category: 0, messages: [], created: Date())
        modelContext.insert(conversation)
    }
    
    func selectConversation(_ conversationId: Conversation.ID?) {
        selectedConversationID = conversationId
    }
    
    func deleteConversation(_ conversationId: Conversation.ID, modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Conversation.self, where: #Predicate { $0.id == conversationId })
        } catch {
            print("채팅방 삭제하는데 오류 발생:\(error.localizedDescription)")
        }
    }
    
    @MainActor
    func sendMessage(
        _ message: Message,
        conversation: Conversation,
        model: Model,
        modelContext: ModelContext
    ) async {
        
        do {
            // conversation의 messages를 통해서 모든 메시지의 내용을 chatsStream에 담아내기
            print("전송하는 데이터: \(message.content)" + message.role.rawValue + " ")
            let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = openAIClient.chatsStream(
                query: ChatQuery(
                    messages:
                        [ChatQuery.ChatCompletionMessageParam(role: message.role, content: String(data: message.content, encoding: String.Encoding.utf8))!]
                    , model: model
                )
            )
            print("전송한 데이터:" + message.content.base64EncodedString())
            
            for try await partialChatResult in chatsStream {
                for choice in partialChatResult.choices { // 대화 내용(content)을 담고 있는 choices
                    let existingMessages = conversation.messages // 합칠 메시지들 가져오기
                    
                    let messageText = choice.delta.content ?? "" // 내화 내용 messageText에 담기
                    print("gpt로부터 받은 text:\(messageText)")
                    // 메시지 만들어내기
                    let message = Message(
                        id: partialChatResult.id,
                        role: choice.delta.role ?? .assistant,
                        content: messageText.data(using: String.Encoding.utf8) ?? Data(),
                        createdAt: Date()
                    )
                    // 메시지의 id가 이전거랑 같다면 덮어 씌우기, 왜냐면 단어는 끊어서 여러개로 나눠 전송되기 때문에.
                    if let existingMessageIndex = existingMessages.firstIndex(where: { $0.id == partialChatResult.id }) {
                        // 이전 메시지가 존재했다면 기존 메시지와 새로운 메시지를 합치기
                        let previousMessage = existingMessages[existingMessageIndex]
                        let combinedMessage = Message( // GPT로부터 받은 메시지를 Message로 구조체에 맞춰서 인스턴스 생성
                            id: message.id, // id stays the same for different deltas
                            role: message.role,
                            content: previousMessage.content + message.content,
                            createdAt: Date()
                        )
                        
                        conversation.messages[existingMessageIndex].content = combinedMessage.content
                        
                    } else {
                        conversation.messages.append(message) // 만약 메시지가 첫번째라서 existingMessages가 없었다면 새로 추가하기
                    }
                }
            }
            
            disableButton = false
        } catch {
            conversationErrors[conversation.id] = error
        }
    }
    
    @MainActor
    func getImage(prompt: String, n: Int, completion: @escaping (String) -> Void) async {
        let query = ImagesQuery(prompt: prompt, model: .dall_e_2,n: 1, size: ._1024)
        openAIClient.images(query: query) { result in
            switch result {
            case .success(let result):
                if let url = result.data.first?.url {
                    completion(url)
                }
            case .failure(let error):
                print("이미지 생성 에러 발생:\(error)")
            }
        }
    }
    

}

