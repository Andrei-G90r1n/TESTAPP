import Foundation

extension Int {
    func formatUnixTimestamp(_ format: String = "dd.MM.YYYY HH:mm") -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}
