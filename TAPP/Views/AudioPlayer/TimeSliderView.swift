import SwiftUI
struct TimeSliderView: View {
    @Binding var currentTime: Double
    let duration: Double
    let onEditingChanged: (Bool, Double) -> Void

    var body: some View {
        VStack {
            Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
                let theNewTime = currentTime
                onEditingChanged(editing, theNewTime)
            })
            .accentColor(.lightGray)

            HStack {
                Text(formatTime(currentTime))
                Spacer()
                Text(formatTime(duration))
            }
            .font(.caption)
            .foregroundColor(.lightGray)
        }
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
