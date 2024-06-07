//
//  SpeechModel.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 5/29/24.
//


import AVFoundation
import Foundation
import OpenAI
import SwiftUI
import Speech

@Observable
class SpeechViewModel: NSObject {
    let openAIClient =  OpenAI(apiToken: KeyChain.shared.getToken() ?? "no Key")
    var selectedVoice: AudioSpeechQuery.AudioSpeechVoice = .alloy {
        didSet { print(selectedVoice.rawValue) }
    }
    var state = VoiceChatState.idle {
        didSet { print(state) }
    }
    var isIdle: Bool {
        if case .idle = state {
            return true
        }
        return false
    }
    
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    
    var recordingSession = AVAudioSession.sharedInstance()
    
    var animationTimer: Timer? //
    var recordingTimer: Timer? // 유저가 말을 멈췄을 때를 위해 사용
    var audioPower = 0.0
    var prevAudioPower: Double?
    var processingSpeechTask: Task<Void, Never>?
    
    var audioLevelHistory: [Double] = []
    let audioLevelThreshold: Double = 0.1 // Adjust this threshold as needed

    var AudioPowerRecords: [CGFloat] = .init(repeating: 0.0, count: 6)
    
    
    var captureURL: URL { // 캡쳐한 url을 저장
        (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("recording.m4a", conformingTo: .audio))!
    }
    
    override init() {
        super.init()
        do {
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            
            AVAudioApplication.requestRecordPermission { [unowned self] allowed in
                if !allowed {
                    self.state = .error("Recording not allowed by the user" as! Error)
                }
            }
        } catch {
            state = .error(error)
        }
    }
    
    
    func startCaptureAudio() {
        resetValues()
        state = .recordingSpeech
        do {
            audioRecorder = try AVAudioRecorder(url: captureURL, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [unowned self] _ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                
                self.audioPower = power
                self.AddAudioPower(value: audioPower)
                
                self.audioLevelHistory.append(power)
                if self.audioLevelHistory.count > 15 {
                    self.audioLevelHistory.removeFirst()
                }
                
                if self.checkAudioLevelsConsistency() {
                    self.finishCaptureAudio()
                }
            })
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: { [unowned self] _ in
                guard self.audioRecorder != nil else { return }
                self.audioRecorder.updateMeters()
                let power = min(1, max(0, 1 - abs(Double(self.audioRecorder.averagePower(forChannel: 0)) / 50) ))
                if self.prevAudioPower == nil {
                    self.prevAudioPower = power
                    return
                }
                if let preAudioPower = self.prevAudioPower, preAudioPower < 0.25 && power < 0.175 {
                    self.finishCaptureAudio()
                }
                self.prevAudioPower = power
            })

        } catch {
            resetValues()
            state = .error(error)
        }
    }
    
    func finishCaptureAudio() {
        resetValues()
        self.state = .processingSpeech
        Task {
            processingSpeechTask = await audio()
        }
    }
    
    func audio() async -> Task<Void, Never> {
        Task { @MainActor in
            do {
                let data = try Data(contentsOf: captureURL)
                let query = AudioTranscriptionQuery(file: data, fileType: AudioTranscriptionQuery.FileType(rawValue: "audio.m4a") ?? .m4a, model: .whisper_1)
                // 음성을 텍스트로 변환하기
                
                try Task.checkCancellation()
                
                let result = try await openAIClient.audioTranscriptions(query: query)
                print("음성을 텍스트로 변환한 결과:" + result.text)
                // 텍스트로 질문하기
                
                try Task.checkCancellation()
                let query2 = CompletionsQuery(model: "gpt-3.5-turbo-instruct", prompt: result.text, temperature: 0, maxTokens: 4000, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
                let result2 = try await openAIClient.completions(query: query2)
                result2.choices.forEach { choice in
                    print("받은값" + choice.text)
                }
                var textArray = ""
                result2.choices.forEach { choice in
                    textArray += choice.text
                }
                
                print("전달받은 텍스트:" + textArray.description)
                
                // 질문 답변 읽게 하기
                let query3 = AudioSpeechQuery(model: .tts_1, input: textArray.description, voice: selectedVoice, responseFormat: .mp3, speed: 1.0)
                let result3 = try await openAIClient.audioCreateSpeech(query: query3)
                print(result3.audio)
                try playAudio(data: result3.audio)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func playAudio(data: Data) throws {
        self.state = .playingSpeech
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.delegate = self
        audioPlayer.play()
    }
    
    func cancelRecording() {
        resetValues()
        state = .idle
    }
    
    func cancelProcessingTask() {
        processingSpeechTask?.cancel()
        processingSpeechTask = nil
        resetValues()
        state = .idle
    }
    
    func resetValues() {
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
        AudioPowerRecords = .init(repeating: 0.0, count: 10)
        audioLevelHistory = []
    }
    
    func AddAudioPower(value: Double) {
        if AudioPowerRecords.count < 10 {
            AudioPowerRecords.append(value)
        } else {
            AudioPowerRecords.removeFirst()
            AudioPowerRecords.append(value)
        }
    }
    
    func checkAudioLevelsConsistency() -> Bool {
        guard audioLevelHistory.count >= 15 else { // 3 seconds * 5 updates per second (0.2 interval)
            return false
        }
        let maxLevel = audioLevelHistory.max() ?? 0
        let minLevel = audioLevelHistory.min() ?? 0
        return (maxLevel - minLevel) <= audioLevelThreshold
    }

    
}

extension SpeechViewModel: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            resetValues() // 녹음이 끝났다면 초기화시키기
            state = .idle
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("flag:\(flag)")
        if flag {
            resetValues()
            state = .idle
        }
    }
}
