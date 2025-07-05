//
//  SoundPickerView.swift
//  SoundCraft
//
//  Created by Abe Malla on 7/4/25.
//

import SwiftUI

struct SoundPickerView: View {
    @Binding var sounds: [Sound]
    @Environment(\.dismiss) var dismiss

    let availableSounds = [
        Sound(name: "Rain", icon: "cloud.rain.fill"),
        Sound(name: "Ocean", icon: "water.waves"),
        Sound(name: "Forest", icon: "leaf.fill"),
        Sound(name: "Fire", icon: "flame.fill"),
        Sound(name: "Wind", icon: "wind"),
        Sound(name: "Thunder", icon: "cloud.bolt.fill"),
        Sound(name: "Birds", icon: "bird.fill"),
        Sound(name: "Night", icon: "moon.stars.fill"),
        Sound(name: "Coffee Shop", icon: "cup.and.saucer.fill"),
        Sound(name: "White Noise", icon: "waveform.circle.fill")
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(availableSounds) { sound in
                    Button(action: {
                        sounds.append(sound)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: sound.icon)
                                .font(.system(size: 24))
                                .frame(width: 40)

                            Text(sound.name)

                            Spacer()
                        }
                    }
                    .disabled(sounds.contains { $0.name == sound.name })
                }
            }
            .navigationTitle("Add Sound")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
