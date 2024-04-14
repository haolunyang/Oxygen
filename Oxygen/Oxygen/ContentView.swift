//
//  ContentView.swift
//  Oxygen
//
//  Created by Haolun Yang on 2/3/24.
//

import SwiftUI
import Combine
import RealityKit

private struct AnimationValues {
    var scale = 1.0
    var verticalOffset = 0.0
}

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(\.openWindow) private var openWindow
    @AppStorage("prompt") var prompt = ""
    
    @EnvironmentObject var viewModel: NotesViewModel
    
    @State private var isAddingNote = false
    @State private var isImmersiveSpaceOpen = false
    @State private var isLoading = false
    @State private var loadingEnded = false
    @State private var animate = false
    @State private var animatedScale = 1.0
    
    @State private var modes = ["Summarize", "Extend"]
    @State private var selectedMode = "Extend"
    
    @State private var responseText = ""
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                orb
                Picker("Please choose a mode", selection: $selectedMode) {
                    ForEach(modes, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .glassBackgroundEffect()
                .frame(maxWidth: 300)
            }
            .offset(z: -240)
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    Button {
                        openWindow(id: "history")
                    } label: {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                    .buttonBorderShape(.circle)
                }
                
                ToolbarItem(placement: .bottomOrnament) {
                    Button {
                        openWindow(id: "note")
                        isAddingNote = true
                    } label: {
                        Image(systemName: "plus")
                            .symbolEffect(.bounce, value: isAddingNote)
                    }
                    .buttonBorderShape(.circle)
                }
                
                ToolbarItem(placement: .bottomOrnament) {
                    Button {
                        isImmersiveSpaceOpen.toggle()
                        
                        if isImmersiveSpaceOpen {
                            Task {
                                await openImmersiveSpace(id: "immersive")
                            }
                        } else {
                            Task {await dismissImmersiveSpace()}
                        }
                    } label: {
                        Label(isImmersiveSpaceOpen ? "Enter Focus Mode" : "Exit Focus Mode", systemImage: isImmersiveSpaceOpen ? "mountain.2.fill" : "mountain.2")
                            .font(.subheadline)
                    }
                    .background(.white.opacity(isImmersiveSpaceOpen ? 0.2 : 0), in: .circle)
                    .buttonBorderShape(.circle)
                }
            }
            inputAndOutput
        }
    }
    
    var orb: some View {
        Button {
            isLoading.toggle()
            let networkManager = NetworkManager()
            
            var promptAddition = ""
            if selectedMode == "Summarize" {
                promptAddition = "- summarize the bullet point of ideas above into a concise, clear, and short paragraph"
            } else {
                promptAddition = "- extend the bullet point of ideas above into a complete, simple, and clear article"
            }
            
            networkManager.sendRequest(prompt: prompt + promptAddition) { result in
                switch result {
                case .success(let responseString):
                    self.responseText = responseString
                    loadingEnded = true
                case .failure(let error):
                    self.responseText = "Error: \(error.localizedDescription)"
                    loadingEnded = true
                }
            }
            
            print(prompt)
        } label: {
            ZStack {
                Model3D(named: "OxygenOrb") { model in
                    model
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .opacity(0.6)
                } placeholder: {
                    ProgressView()
                        .frame(width: 240, height: 240)
                }
                .offset(y: -10)
                .keyframeAnimator(
                    initialValue: AnimationValues(),
                    trigger: isLoading
                ) { content, value in
                    content
                        .scaleEffect(value.scale)
                        .offset(y: value.verticalOffset)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(1, duration: 1)
                        CubicKeyframe(0.8, duration: 1)
                        CubicKeyframe(1, duration: 1)
                        CubicKeyframe(0.8, duration: 1)
                        CubicKeyframe(1, duration: 1)
                    }
                }
                .keyframeAnimator(
                    initialValue: AnimationValues(),
                    trigger: loadingEnded
                ) { content, value in
                    content
                        .scaleEffect(value.scale)
                        .offset(y: value.verticalOffset)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        CubicKeyframe(0.75, duration: 0.3)
                        CubicKeyframe(1, duration: 0.3)
                    }
                }
            }
            .frame(minWidth: 240, minHeight: 240)
        }
        .buttonStyle(.plain)
    }
    
    var inputAndOutput: some View {
        HStack(spacing: 15) {
            TextEditor(text: $prompt)
                .font(.title3)
                .glassBackgroundEffect(in: .rect(cornerRadius: 30, style: .continuous))
                .frame(width: 300, height: 250)
                .padding(.vertical)
                .overlay {
                    if prompt.isEmpty {
                        HStack {
                            Image(systemName: "brain")
                            Text("Add your thoughts")
                                .font(.title3)
                        }
                        .foregroundStyle(.tertiary)
                        .frame(width: 260, height: 216, alignment: .topLeading)
                    }
                }
            
            TextEditor(text: $responseText)
                .font(.title3)
                .glassBackgroundEffect(in: .rect(cornerRadius: 30, style: .continuous))
                .frame(width: 300, height: 250)
                .padding(.vertical)
                .overlay {
                    if responseText.isEmpty {
                        HStack {
                            Image(systemName: "sparkles")
                            Text(selectedMode == "Extend" ? "Extended result" : "Summarized result")
                                .font(.title3)
                        }
                        .foregroundStyle(.tertiary)
                        .frame(width: 260, height: 216, alignment: .topLeading)
                    }
                }
                .disabled(responseText.isEmpty)
        }
    }
}
