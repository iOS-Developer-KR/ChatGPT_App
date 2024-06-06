//
//  DataModel.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/25/24.
//


import Foundation
import OpenAI
import SwiftData

enum Category: String, Codable {
    case text
    case image
}

extension Conversation: Identifiable {}

@Model
class Conversation: Hashable {
    init(id: String, category: Int, messages: [Message] = [], created: Date) {
        self.id = id
        self.category = category
        self.messages = messages
        self.created = created
    }
    
    typealias ID = String
    
    let id: String
    var category: Int
    var messages: [Message]
    var created: Date
}

//extension ImageConversation: Identifiable {}
//
//@Model
//class ImageConversation {
//    init(id: String, message: [ImageMessage] = [], created: Date) {
//        self.id = id
//        self.messages = message
//        self.created = created
//    }
//    
//    let id: String
//    var messages: [ImageMessage]
//    var created: Date
//}


