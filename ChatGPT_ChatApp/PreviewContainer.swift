//
//  PreviewContainer.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/25/24.
//

import Foundation
import SwiftData

@MainActor
let previewRoutineContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Conversation.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))

        SampleData.conversation.forEach { conversation in
            container.mainContext.insert(conversation)
        }
        print("성공인데..")
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

struct SampleData {
    
    static let conversation: [Conversation] = {
        return [Conversation(id: "1", category: 0, messages: [Message(id: "1", role: .user, content: Data(), createdAt: Date()-5),
                                                 Message(id: "2", role: .assistant, content: Data(), createdAt: Date()-4),
                                                 Message(id: "3", role: .user, content: Data(), createdAt: Date()-3),
                                                 Message(id: "4", role: .assistant, content: Data(), createdAt: Date()-2),
                                                 Message(id: "5", role: .user, content: Data(), createdAt: Date()-1),
                                                 Message(id: "6", role: .assistant, content: Data(), createdAt: Date()),
                                                 Message(id: "7", role: .user, content: Data(), createdAt: Date()-5),
                                                  Message(id: "8", role: .assistant, content: Data(), createdAt: Date()-6),
                                                  Message(id: "9", role: .user, content: Data(), createdAt: Date()-7),
                                                  Message(id: "10", role: .assistant, content: Data(), createdAt: Date()-8),
                                                  Message(id: "11", role: .user, content: Data(), createdAt: Date()-9),
                                                  Message(id: "12", role: .assistant, content: Data(), createdAt: Date()-10),
                                                 Message(id: "13", role: .user, content: Data(), createdAt: Date()-11),
                                                 Message(id: "14", role: .assistant, content: Data(), createdAt: Date()-12),
                                                 Message(id: "15", role: .user, content: Data(), createdAt: Date()-13),
                                                 Message(id: "16", role: .assistant, content: Data(), createdAt: Date()-14),
                                                 
                                                ], created: Date())
        ]
    }()
//    static let conversation: [Conversation] = {
//        return [Conversation(id: "1", messages: [Message(id: "1", role: .user, content: "user1", createdAt: Date()-5),
//                                                 Message(id: "2", role: .assistant, content: "assistent1", createdAt: Date()-4),
//                                                 Message(id: "3", role: .user, content: "user2", createdAt: Date()-3),
//                                                 Message(id: "4", role: .assistant, content: "assistent2", createdAt: Date()-2),
//                                                 Message(id: "5", role: .user, content: "user3", createdAt: Date()-1),
//                                                 Message(id: "6", role: .assistant, content: "assistent3", createdAt: Date()),
//                                                 Message(id: "7", role: .user, content: "user1", createdAt: Date()-5),
//                                                  Message(id: "8", role: .assistant, content: "assistent1", createdAt: Date()-6),
//                                                  Message(id: "9", role: .user, content: "user2", createdAt: Date()-7),
//                                                  Message(id: "10", role: .assistant, content: "assistent2", createdAt: Date()-8),
//                                                  Message(id: "11", role: .user, content: "user3", createdAt: Date()-9),
//                                                  Message(id: "12", role: .assistant, content: "assistent3", createdAt: Date()-10),
//                                                 Message(id: "13", role: .user, content: "user2", createdAt: Date()-11),
//                                                 Message(id: "14", role: .assistant, content: "assistent2", createdAt: Date()-12),
//                                                 Message(id: "15", role: .user, content: "user3", createdAt: Date()-13),
//                                                 Message(id: "16", role: .assistant, content: "assistent3", createdAt: Date()-14),
//                                                 
//                                                ], created: Date())
//        ]
//    }()
}
