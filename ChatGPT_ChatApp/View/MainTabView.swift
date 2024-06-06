//
//  MainTabView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/26/24.
//

import SwiftUI

struct MainTabView: View {
    @Environment(KeyChain.self) var keychain
    
    var body: some View {
        TabView {
            MainView()
                .tabItem { Label("Message", systemImage: "message") }
            
            ImageView()
                .tabItem { Label("Image", systemImage: "photo") }
            
            SpeechView()
                .tabItem { Label("Voice", systemImage: "mic") }
            
            SettingView()
                .tabItem { Label("Setting", systemImage: "gear") }
            
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(previewRoutineContainer)
        .environment(ChatGPT())
}
