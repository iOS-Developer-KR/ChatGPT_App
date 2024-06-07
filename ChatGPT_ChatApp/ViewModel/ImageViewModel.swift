//
//  ImageViewModel.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 6/2/24.
//

import Foundation
import OpenAI
import SwiftUI
import SwiftData
import Combine
import Alamofire

enum GPTError: String, Error {
    case unsafe = "Your request was rejected as a result of our safety system. Your prompt may contain text that is not allowed by our safety system."
    case nodata = "No Data, Check your Internet connection"
}

@Observable
public final class ImageViewModel {
    let openAIClient = OpenAI(apiToken: KeyChain.shared.getToken() ?? "no Key")
    
    var disableButton: Bool = false
    var showAlert: Bool = false
    var alertMessage: String = ""


    // MARK: - Events
    func createConversation(modelContext: ModelContext) {
        let conversation = Conversation(id: UUID().uuidString, category: 1, messages: [], created: Date())
        modelContext.insert(conversation)
    }
    
    func deleteConversation(_ conversationId: Conversation.ID, modelContext: ModelContext) {
        do {
            try modelContext.delete(model: Conversation.self, where: #Predicate { $0.id == conversationId })
        } catch {
            print("채팅방 삭제하는데 오류 발생:\(error.localizedDescription)")
        }
    }
    
    @MainActor
    func getImage(conversation: Conversation, prompt: String, model: Model, n: Int, completion: @escaping (String) -> Void) async {
        let query = ImagesQuery(prompt: prompt, model: model, n: 1, size: ._1024)
        openAIClient.images(query: query) { result in
            switch result {
            case .success(let result):
                if let url = result.data.first?.url {
                    AF.request(url)
                        .validate(statusCode: 200..<300)
                        .responseData { [weak self] response in
                            switch response.result {
                            case .success:
                                if let data = response.data {
                                    conversation.messages.append(Message(id: UUID().uuidString, role: .assistant, content: data, createdAt: Date()))
                                }
                            case .failure:
                                self?.showAlert = true
                                self?.alertMessage = GPTError.nodata.rawValue
                            }
                        }
                }
            case .failure(let error):
                print("여기2" + error.localizedDescription)
                completion(GPTError.unsafe.rawValue)
                self.showAlert = true
                self.alertMessage = GPTError.unsafe.rawValue
            }
        }
        self.disableButton = false
    }

}
