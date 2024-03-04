import Foundation

protocol DateFormatter {
    func string(from date: Date) -> String
}

extension Foundation.DateFormatter: DateFormatter {}
extension ISO8601DateFormatter: DateFormatter {}

func BuildDateFormatter(for identifier: String?) -> any DateFormatter {
    guard let identifier = identifier else {
        return ISO8601DateFormatter()
    }
    
    let formatter = Foundation.DateFormatter()
    switch identifier {
    case "short":
        formatter.dateStyle = .short
        formatter.timeStyle = .short
    case "medium":
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
    case "long":
        formatter.dateStyle = .long
        formatter.timeStyle = .long
    case "full":
        formatter.dateStyle = .full
        formatter.timeStyle = .full
    default:
        formatter.dateFormat = identifier
    }
    return formatter
}
