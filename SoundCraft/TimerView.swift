//
//  TimerView.swift
//  SoundCraft
//
//  Created by Abe Malla on 7/4/25.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedHours = 0
    @State private var selectedMinutes = 30

    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                HStack(spacing: 20) {
                    // Hours Picker
                    VStack {
                        Text("Hours")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                    }

                    Text(":")
                        .font(.title)

                    // Minutes Picker
                    VStack {
                        Text("Minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0..<60) { minute in
                                Text(String(format: "%02d", minute))
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                    }
                }
                .padding(.top, 40)

                Button("Start Timer") {
                    // Start timer logic here
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()
            }
            .navigationTitle("Sleep Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
