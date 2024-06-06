//
//  SpeechView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/29/24.
//

import SwiftUI
import OpenAI

struct SpeechView: View {
    @Environment(ChatGPT.self) var chat
    @Environment(SpeechViewModel.self) var speech
    @State var isSymbolAnimating = false
    @State private var isBounced = false
    
    var body: some View {
        NavigationStack {
            Spacer()
            
            VStack {
                Spacer()
                
                VoiceAnimationView()
                    .overlay { overlayView }
                
                Spacer()
                
                switch speech.state {
                case .recordingSpeech:
                    cancelRecordingButton
                case .processingSpeech, .playingSpeech:
                    cancelButton
                default: EmptyView()
                }
            }
            
            Spacer()
            
            @Bindable var speechs = speech
            Picker("Voice Selection", selection: $speechs.selectedVoice) {
                ForEach(AudioSpeechQuery.AudioSpeechVoice.allCases, id: \.self) {
                    Text($0.rawValue).id($0)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!speech.isIdle)
        }
        .onAppear {
            isSymbolAnimating = true
        }
    }
    
    @ViewBuilder
    var overlayView: some View {
        switch speech.state {
        case .idle, .error:
            startCaptureButton
        case .processingSpeech:
            Image(systemName: "ellipsis")
                .symbolEffect(.variableColor, options: .repeating, value: isSymbolAnimating)
                .font(.system(size: 128))
                .onAppear { isSymbolAnimating = true }
                .onDisappear { isSymbolAnimating = false }
        case .playingSpeech:
            Image(systemName: "brain")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150)
                .symbolEffect(.bounce.up.byLayer, options: .repeating, value: isSymbolAnimating)
                .font(.system(size: 128))
                .onAppear { isSymbolAnimating = true }
                .onDisappear { isSymbolAnimating = false }
        default: EmptyView()
        }
    }
    
    var startCaptureButton: some View {
        Button {
            speech.startCaptureAudio()
        } label: {
            Image(systemName: "mic.circle")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 128))
                .scaleEffect(isBounced ? 1.0 : 1.2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                        isBounced.toggle()
                    }
                }
        }
        .buttonStyle(.borderless)
    }
    
    var cancelRecordingButton: some View {
        Button(role: .destructive) {
            speech.cancelRecording()
            withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                isBounced.toggle()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 44))
        }.buttonStyle(.borderless)
    }
    
    var cancelButton: some View {
        Button(role: .destructive) {
            speech.cancelProcessingTask()
            withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                isBounced.toggle()
            }
        } label: {
            Image(systemName: "stop.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
                .font(.system(size: 44))
        }.buttonStyle(.borderless)
    }
}

#Preview {
    SpeechView()
        .environment(ChatGPT())
        .environment(SpeechViewModel())
}

#Preview("Recording Speech") {
    @State var vm = SpeechViewModel()
    @State var vm2 = ChatGPT()
    vm.state = .recordingSpeech
    vm.audioPower = 0.2
    return SpeechView()
        .environment(vm)
        .environment(vm2)
}

#Preview("Processing Speech") {
    @State var vm = SpeechViewModel()
    @State var vm2 = ChatGPT()
    vm.state = .processingSpeech
    return SpeechView()
        .environment(vm)
        .environment(vm2)
}

#Preview("Playing Speech") {
    @State var vm = SpeechViewModel()
    @State var vm2 = ChatGPT()
    vm.state = .playingSpeech
    vm.audioPower = 0.3
    return SpeechView()
        .environment(vm)
        .environment(vm2)
}
