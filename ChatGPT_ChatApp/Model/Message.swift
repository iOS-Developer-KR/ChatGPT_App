//
//  Message.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/25/24.
//

import Foundation
import OpenAI
import SwiftData

@Model
class Message {
    @Attribute(.unique) var id: String
    var role: ChatQuery.ChatCompletionMessageParam.Role
    var content: Data
    var createdAt: Date
    
    init(id: String, role: ChatQuery.ChatCompletionMessageParam.Role, content: Data, createdAt: Date) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
    
}

extension Message: Identifiable {}


//@Model
//class ImageMessage {
//    @Attribute(.unique) var id: String
//    var role: ChatQuery.ChatCompletionMessageParam.Role
//    var url: String
//    var createdAt: Date
//    
//    init(id: String, role: ChatQuery.ChatCompletionMessageParam.Role, url: String, createdAt: Date) {
//        self.id = id
//        self.role = role
//        self.url = url
//        self.createdAt = createdAt
//    }
//    
//}
//
//extension ImageMessage: Identifiable {}
//
