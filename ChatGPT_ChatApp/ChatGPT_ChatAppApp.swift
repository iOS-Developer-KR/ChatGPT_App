//
//  ChatGPT_ChatAppApp.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/25/24.
//

import SwiftUI
import SwiftData

@main
struct ChatGPT_ChatAppApp: App {
    @AppStorage("userLanguageKey") private var locale = "en"

    @State private var gpt = ChatGPT()
    @State private var image = ImageViewModel()
    @State private var speech = SpeechViewModel()
    @State private var keychain = KeyChain()
    @State var languageSettings = LanguageSetting()

    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Conversation.self)
            keychain.getToken()
            languageSettings.locale = Locale(identifier: locale)
        } catch {
            fatalError("모델 컨테이너 초기화 실패")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if keychain.exist {
                MainTabView()
            } else {
                APIKeyView()
            }
        }
        .environment(gpt)
        .environment(image)
        .environment(speech)
        .environment(keychain)
        .environment(languageSettings)
        .environment(\.locale, languageSettings.locale)
        .modelContainer(modelContainer)
        
    }
}
