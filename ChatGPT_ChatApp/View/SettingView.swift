//
//  ContentView.swift
//  SettingViewUI
//
//  Created by Taewon Yoon on 6/1/24.
//

import SwiftUI
import SwiftData

enum Language: String, CaseIterable {
    case en
    case es
    case fr
    case ko
    case ja // 일본어 추가

    var value: String {
        switch self {
        case .en:
            return "en"
        case .es:
            return "es"
        case .fr:
            return "fr"
        case .ko:
            return "ko"
        case .ja:
            return "ja"
        }
    }
}


struct SettingView: View {
    @Environment(LanguageSetting.self) var languageSettings
    @Environment(KeyChain.self) var keychain
    @Environment(\.modelContext) var dbContext
    @AppStorage("userLanguageKey") private var locale = "en"

    @State var language: Language = .ko
    @State var removeCached: Bool = false
    @State var logout: Bool = false
    
    @Query var conversations: [Conversation]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(LocalizedStringKey("Setting"))) {
                    Picker("Select Language", selection: $language) {
                        Text("Korean").tag(Language.ko)
                        Text("English").tag(Language.en)
                        Text("Japanese").tag(Language.ja)
                    }
                    HStack {
                        Button {
                            removeCached.toggle()
                        } label: {
                            Text("Remove Cached Data")
                        }
                    }
                    
                    Button {
                        logout.toggle()
                    } label: {
                        Text("Logout")
                            .foregroundStyle(Color.red)
                    }
                }
            }
        }
        .onAppear {
            language = Language.allCases.first { language in
                language.value == locale
            }!
        }
        .onChange(of: language, { oldValue, newValue in
            languageSettings.locale = Locale(identifier: newValue.value)
            locale = newValue.value
        })
        .alert("Confirm", isPresented: $removeCached) {
            Button("CANCEL", role: .cancel) {}
            Button("OK", role: .destructive) {
                try? dbContext.delete(model: Conversation.self)
            }
        } message: {
            Text("Are you sure you want to remove all the cached data?\n If you remove the cache, you will not be able to see the recorded chat")
        }
        .alert("Confirm", isPresented: $logout) {
            Button("CANCEL", role: .cancel) {}
            Button("OK", role: .destructive) {
                try? keychain.removeToken()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}

#Preview {
    SettingView()
        .environment(LanguageSetting())
}
