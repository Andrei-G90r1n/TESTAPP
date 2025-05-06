import SwiftUI

struct PlaybackControlsView: View {
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.lightGray)
        }
    }
}
