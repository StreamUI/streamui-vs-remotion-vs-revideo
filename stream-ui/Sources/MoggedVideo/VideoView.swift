//
//  File.swift
//
//
//  Created by Jordan Howlett on 6/26/24.
//

import StreamUI
import SwiftUI

let width = 1080.0
let height = 1920.0

public struct VideoView: View {
    @Environment(\.recorder) private var recorder
    let openSkill = OpenSkillHelper()

    let people: [Person]

    var person1: Person {
        return people[(currentRound * 2) % people.count]
    }

    var person2: Person {
        return people[(currentRound * 2 + 1) % people.count]
    }

    var height: Double {
        if let height = recorder?.renderSettings.height {
            return Double(height)
        }
        return 1920.0
    }

    @State private var currentRound: Int = 0
    @State private var isVoting: Bool = true
    @State private var progress: CGFloat = 1.0
    @State private var showResults: Bool = false

    public init(people: [Person]) {
        self.people = people
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                let person1Score = openSkill.rating(mu: person1.openskillMu, sigma: person1.openskillSigma)
                let person2Score = openSkill.rating(mu: person2.openskillMu, sigma: person2.openskillSigma)

                let predictions = openSkill.predictWin([[person1Score], [person2Score]])
                let (probability1, probability2) = (predictions[0], predictions[1])

                let percent1 = Int(round(probability1 * 100))
                let percent2 = Int(round(probability2 * 100))

                VStack(spacing: 0) {
                    PersonImageView(person: person1, percentage: percent1, showResults: showResults, height: height / 2)
                        .id(person1.id)
                    PersonImageView(person: person2, percentage: percent2, showResults: showResults, height: height / 2)
                        .id(person2.id)
                }

                VStack {
                    Spacer()
                    Text(isVoting ? "Who's hotter?" : "Results")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.pink)
                        .background(Color.black)
                        .padding(-10)

                    CountdownBar(progress: $progress)
                        .frame(height: 40)
//                        .background(.red)

                    Text("Vote @ www.mogged.ai")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .background(Color.black)
                        .padding(-10)
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .onAppear(perform: startTimer)
    }

    private func startTimer() {
        Task {
            for iteration in 0..<5 { // Run for 5 iterations
                // Voting state
                isVoting = true
                showResults = false
                progress = 1.0

                // Count time the progress
                for _ in 0..<300 { // 3 seconds, 100 steps per second
                    progress -= 1.0 / 300
                    try await recorder?.controlledClock.clock.sleep(for: .milliseconds(10))
                }

                // Score state
                isVoting = false
                showResults = true

                // Show scores for 1.5 seconds
                try await recorder?.controlledClock.clock.sleep(for: .milliseconds(1500))

                // Move to next round
                currentRound += 1
            }

            // After 5 iterations, stop recording
            await recorder?.stopRecording()
        }
    }
}

struct CountdownBar: View {
    @Binding var progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.white)
                Rectangle()
                    .foregroundColor(.green)
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}

struct PersonImageView: View {
    let person: Person
    let percentage: Int
    let showResults: Bool
    let height: Double

    var body: some View {
        StreamingImage(url: URL(string: person.image), scaleType: .fill)
            .frame(height: height)
            .clipped()
            .overlay(
                VStack {
                    if showResults {
                        Text("\(percentage)%")
                            .font(.system(size: 200, weight: .black))
                            .foregroundColor(percentage > 50 ? .green : .red)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(50)
                            .padding()
                    }
                    Text("\(person.flag) \(person.name)")
                        .font(.system(size: 60, weight: .black))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding(.bottom, 100),
                alignment: .bottom
            )
    }
}
