//
//  SpeechRecognizerViewModel.swift
//  COMP90018_APP
//
//  Created by frank w on 28/10/2023.
//

import Foundation
import Speech



class SpeechRecognizerViewModel: ObservableObject {
    // Capture all speech text and specific text
    @Published var speechText: String = "Capture all speech text"
    @Published var commandText: String = "Say 'hi hotpot' to wake me up..."
    @Published var isListening: Bool = false
    @Published var commandListerning: Bool = false
    @Published var inProgress: Bool = false
    @Published var showingPermissionAlert = false
    
    
    var wakeUpText: String = "hi hotpot"


    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var resetTimer: Timer?

    
    func checkAndStartListening() {
            self.inProgress = true
            // First, check microphone permission
            switch AVAudioSession.sharedInstance().recordPermission {
            case .denied:
                self.showingPermissionAlert = true
                self.inProgress = false
                return
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                    if granted {
                        // If granted, then check speech recognition permission
                        self?.checkSpeechRecognitionPermission()
                    } else {
                        self?.showingPermissionAlert = true
                        self?.inProgress = false
                    }
                }
                return
            case .granted:
                // If microphone permission is already granted, check speech recognition
                checkSpeechRecognitionPermission()
            @unknown default:
                self.showingPermissionAlert = true
                self.inProgress = false
            }
        }

        private func checkSpeechRecognitionPermission() {
            SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        // Both permissions are authorized
                        self?.startListening()
                    default:
                        self?.showingPermissionAlert = true
                        self?.inProgress = false
                    }
                }
            }
        }
    
    
    func startListening() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self, let result = result else { return }

            self.speechText = result.bestTranscription.formattedString
//            self.restartResetTimer()
            
            if self.speechText.lowercased().contains(wakeUpText) {
                DispatchQueue.main.async {
                    self.commandText = self.speechText
                    self.commandListerning = true
                }
            }
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
            self.inProgress = false
        } catch {
            print("audioEngine couldn't start because of an error.")
            isListening = false
            self.inProgress = false
        }
    }

    func stopListening() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isListening = false
        
        recognitionTask = nil
        recognitionRequest = nil
        
    }
    
    // Reset all speech text
    func resetSpeechTexts(){
        DispatchQueue.main.async {
            self.speechText = ""
            self.commandText = ""
            self.commandListerning = false
        }
        
        // Stop current speech recognition and start anew
        stopListening()
        startListening()
    }
    
    // Start or Restart the Timer
        private func restartResetTimer() {
            resetTimer?.invalidate()
            resetTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.resetSpeechTexts()
            }
        }

    


}

