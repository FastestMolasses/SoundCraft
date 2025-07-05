//
//  ContentView.swift
//  SoundCraft
//
//  Created by Abe Malla on 7/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var sounds: [Sound] = [
        Sound(name: "Rain", icon: "cloud.rain.fill"),
        Sound(name: "Ocean", icon: "water.waves"),
        Sound(name: "Forest", icon: "leaf.fill"),
        Sound(name: "Fire", icon: "flame.fill")
    ]
    @State private var isPlaying = false
    @State private var showingSoundPicker = false
    @State private var showingTimer = false

    var body: some View {
        ZStack {
            // Background
            Color(hex: "d0e6f7")
                .ignoresSafeArea()

            // Sound Grid
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 0),
                        GridItem(.flexible(), spacing: 0)
                    ], spacing: 50) {
                        ForEach($sounds) { $sound in
                            SoundButton(sound: $sound) {
                                withAnimation(.spring()) {
                                    sounds.removeAll { $0.id == sound.id }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 60)
                    .padding(.bottom, 120)
                }

                Spacer()
            }

            // Bottom Controls
            VStack {
                Spacer()

                HStack(spacing: 40) {
                    // Timer Button
                    Button(action: { showingTimer.toggle() }) {
                        Image(systemName: "timer")
                            .frame(width: 60, height: 60)
                            .font(.system(size: 24))
                            .foregroundStyle(.foreground)
                            .glassEffect()
                    }
                    .glassEffect()

                    // Add Sound Button
                    Button(action: { showingSoundPicker.toggle() }) {
                        Image(systemName: "plus")
                            .frame(width: 120, height: 60)
                            .font(.system(size: 24))
                            .foregroundStyle(.foreground)
                            .glassEffect()
                    }
                    .glassEffect()

                    // Play/Pause Button
                    Button(action: { isPlaying.toggle() }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .frame(width: 60, height: 60)
                            .font(.system(size: 24))
                            .foregroundStyle(.foreground)
                            .glassEffect()
                    }
                    .glassEffect()
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showingSoundPicker) {
            SoundPickerView(sounds: $sounds)
        }
        .sheet(isPresented: $showingTimer) {
            TimerView()
        }
    }
}
