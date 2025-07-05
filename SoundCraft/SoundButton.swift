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
    @State private var showingName = false
    @State private var initialVolume: Double = 0
    @State private var startDragPosition: CGFloat = 0
    /// 0 to 1, represents how far into delete gesture we are
    @State private var deleteProgress: Double = 0
    @State private var hasReachedDeleteThreshold = false
    @State private var isDeleting = false
    /// Position where volume first reached 0
    @State private var zeroVolumePosition: CGFloat? = nil

    private let buttonWidth: CGFloat = 170
    private let buttonHeight: CGFloat = 90
    /// When to trigger delete haptic and show trash
    private let deleteThreshold: Double = 0.4

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background pill shape
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .fill(.clear)
                    .frame(width: buttonWidth, height: buttonHeight)
                    .glassEffect()

                // Delete button background (appears when swiping left)
                if deleteProgress > 0 {
                    HStack {
                        Spacer(minLength: 0)

                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: buttonHeight / 2,
                            topTrailingRadius: buttonHeight / 2
                        )
                        .fill(Color.red.opacity(0.8))
                        .frame(width: buttonWidth * deleteProgress, height: buttonHeight)
                        .overlay(
                            // Trash icon appears when threshold is reached
                            Group {
                                if hasReachedDeleteThreshold {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                        .scaleEffect(hasReachedDeleteThreshold ? 1.0 : 0.8)
                                        .animation(.interactiveSpring(response: 0.15), value: hasReachedDeleteThreshold)
                                }
                            }
                        )
                        .animation(.interactiveSpring(response: 0.15, dampingFraction: 1.0), value: deleteProgress)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: buttonHeight / 2))
                }

                // Volume fill overlay
                HStack {
                    UnevenRoundedRectangle(
                        topLeadingRadius: buttonHeight / 2,
                        bottomLeadingRadius: buttonHeight / 2,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0
                    )
                    .fill(fillColor)
                    .frame(width: (buttonWidth * sound.volume) * (1 - deleteProgress), height: buttonHeight)
                    .animation(.interactiveSpring(response: 0.15, dampingFraction: 1.0), value: sound.volume)
                    .animation(.interactiveSpring(response: 0.15, dampingFraction: 1.0), value: deleteProgress)
                    .animation(.easeOut(duration: 0.2), value: isDragging)

                    Spacer(minLength: 0)
                }
                .clipShape(RoundedRectangle(cornerRadius: buttonHeight / 2))

                // Icon and text overlay
                if !isDeleting {
                    VStack(spacing: 2) {
                        Image(systemName: sound.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.primary)
                            .scaleEffect(isDragging ? 0.95 : 1.0)
                            .animation(.interactiveSpring(response: 0.15), value: isDragging)

                        // Sound name label
                        if showingName {
                            Text(sound.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                    }
                    .opacity(max(0, 1 - deleteProgress * 2.0))
                    .animation(.easeOut(duration: 0.15), value: deleteProgress)
                }
            }
        }
        .frame(width: buttonWidth, height: buttonHeight)
        .contentShape(RoundedRectangle(cornerRadius: buttonHeight / 2))
        .transition(.opacity.animation(.easeOut(duration: 0.25)))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isDragging {
                        initialVolume = sound.volume
                        startDragPosition = value.startLocation.x

                        if sound.volume <= 0 {
                            zeroVolumePosition = value.startLocation.x
                        } else {
                            zeroVolumePosition = nil
                        }

                        withAnimation(.interactiveSpring(response: 0.15)) {
                            isDragging = true
                            showingName = true
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }

                    // Calculate volume change based on drag distance from start position
                    let dragDistance = value.location.x - startDragPosition
                    let volumeChange = dragDistance / buttonWidth
                    let newVolume = max(0, min(1, initialVolume + volumeChange))

                    if newVolume <= 0 && sound.volume > 0 {
                        zeroVolumePosition = value.location.x
                    }

                    // If we're dragging left past zero volume, start delete gesture
                    if newVolume <= 0 && volumeChange < 0 {
                        sound.volume = 0

                        // Calculate delete progress from the point where volume reached zero
                        if let zeroPos = zeroVolumePosition {
                            let deleteDistance = max(0, zeroPos - value.location.x) / buttonWidth
                            let newDeleteProgress = min(1.0, deleteDistance * 2) // Scale the delete progress

                            deleteProgress = newDeleteProgress

                            // Check if we've reached the delete threshold
                            if newDeleteProgress >= deleteThreshold && !hasReachedDeleteThreshold {
                                hasReachedDeleteThreshold = true
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            } else if newDeleteProgress < deleteThreshold && hasReachedDeleteThreshold {
                                hasReachedDeleteThreshold = false
                            }
                        }
                    } else {
                        // Normal volume adjustment
                        if abs(newVolume - sound.volume) > 0.01 {
                            sound.volume = newVolume

                            if abs(newVolume - sound.volume) > 0.1 {
                                let selectionFeedback = UISelectionFeedbackGenerator()
                                selectionFeedback.selectionChanged()
                            }
                        }

                        // Reset delete progress if we're not in delete zone
                        if deleteProgress > 0 {
                            deleteProgress = 0
                            hasReachedDeleteThreshold = false
                            zeroVolumePosition = nil
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        isDragging = false
                    }

                    if hasReachedDeleteThreshold {
                        performDeletion()
                    } else {
                        // Reset delete progress
                        withAnimation(.easeOut(duration: 0.3)) {
                            deleteProgress = 0
                            hasReachedDeleteThreshold = false
                        }
                        zeroVolumePosition = nil

                        // Hide the name after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showingName = false
                            }
                        }

                        if sound.volume < 0.05 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                sound.volume = 0
                            }
                        }
                    }

                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
        )
    }

    private func performDeletion() {
        isDeleting = true

        // Animation sequence: expand delete button, then shrink and delete
        withAnimation(.easeOut(duration: 0.2)) {
            deleteProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                deleteProgress = 0.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onDelete()
            }
        }
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
