//
//  SoundButton.swift
//  SoundCraft
//
//  Created by Abe Malla on 7/4/25.
//

import SwiftUI

struct SoundButton: View {
    @Binding var sound: Sound
    let onDelete: () -> Void

    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0

    private let buttonWidth: CGFloat = 160
    private let buttonHeight: CGFloat = 80

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background pill shape
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .fill(.clear)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .glassEffect()

                // Volume fill overlay
                HStack {
                    UnevenRoundedRectangle(
                        topLeadingRadius: buttonHeight / 2,
                        bottomLeadingRadius: buttonHeight / 2,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                    .fill(fillColor)
                    .frame(width: buttonWidth * sound.volume, height: buttonHeight)
                    .animation(.interactiveSpring(response: 0.15, dampingFraction: 1.0), value: sound.volume)
                    .animation(.easeOut(duration: 0.2), value: isDragging)

                    Spacer(minLength: 0)
                }
                .clipShape(RoundedRectangle(cornerRadius: buttonHeight / 2))

                // Icon and text overlay
                VStack(spacing: 2) {
                    Image(systemName: sound.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.primary)
                        .scaleEffect(isDragging ? 0.95 : 1.0)
                        .animation(.interactiveSpring(response: 0.15), value: isDragging)

                    if isDragging {
                        Text(sound.name)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }
            }
        }
        .frame(width: buttonWidth, height: buttonHeight)
        .contentShape(RoundedRectangle(cornerRadius: buttonHeight / 2))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isDragging {
                        withAnimation(.interactiveSpring(response: 0.15)) {
                            isDragging = true
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }

                    let newVolume = max(0, min(1, value.location.x / buttonWidth))

                    // Only update if there's a meaningful change to avoid excessive updates
                    if abs(newVolume - sound.volume) > 0.01 {
                        sound.volume = newVolume

                        if abs(newVolume - sound.volume) > 0.1 {
                            let selectionFeedback = UISelectionFeedbackGenerator()
                            selectionFeedback.selectionChanged()
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        isDragging = false
                    }

                    if sound.volume < 0.05 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            sound.volume = 0
                        }
                    }

                    // Haptic feedback on drag end
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                sound.isPlaying.toggle()
            }

            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        .glassEffect()
    }

    private var fillColor: Color {
        let baseColor = Color.white

        if isDragging {
            return baseColor.opacity(0.75)
        } else if sound.volume > 0 {
            return baseColor.opacity(0.25)
        } else {
            return baseColor.opacity(0.1)
        }
    }
}
