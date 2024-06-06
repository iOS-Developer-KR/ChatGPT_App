//
//  VoiceAnimationView.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/31/24.
//

import SwiftUI

struct VoiceAnimationView: View {
 
    @Environment(SpeechViewModel.self) var speechvm
    @State private var drawingHeight = true
    
 
    var animation: Animation {
        return .linear(duration: 0.5).repeatForever()
    }
 
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ForEach(Array(speechvm.AudioPowerRecords.enumerated().reversed()), id: \.offset) { index, value in
                    bar(high: value)
                        .animation(.easeInOut(duration: 0.3), value: value)
                }
            }
            .frame(width: 80)
            .onAppear{
                drawingHeight.toggle()
            }
        }
        .onAppear {
            drawingHeight.toggle()
        }
    }
 
    func bar(high: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(.green.gradient)
            .frame(width: 15, height: high*200, alignment: .bottom)
    }
}

#Preview {
    VoiceAnimationView()
        .environment(SpeechViewModel())
}
