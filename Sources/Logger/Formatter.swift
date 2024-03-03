import Foundation
import os

enum FormatError: Error {
    case invalidFormat
    case unknownField(String)
}

protocol DateFormatter {
    func string(from date: Date) -> String
}

extension Foundation.DateFormatter: DateFormatter {}
extension ISO8601DateFormatter: DateFormatter {}

final class FormatterStorage: @unchecked Sendable {
    private let lock: OSAllocatedUnfairLock<[String?:DateFormatter]>
    
    init() {
        lock = OSAllocatedUnfairLock(initialState: [:])
    }
    
    private func generateFormatter(for identifier: String?) -> DateFormatter {
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
    
    subscript(_ identifier: String?) -> DateFormatter {
        get {
            lock.withLock { formatters in
                if let formatter = formatters[identifier] {
                    return formatter
                } else {
                    let formatter = generateFormatter(for: identifier)
                    formatters[identifier] = formatter
                    return formatter
                }
            }
        }
    }
}

let formatters = FormatterStorage()
func extractor(for property: String) throws -> (LogEntry) -> String {
    let parts = property.split(separator: "|", maxSplits: 2)
    let field: String
    let qualifier: String?
    if parts.count == 2, let first = parts.first, let last = parts.last {
        field = String(first)
        qualifier = String(last)
    } else if let first = parts.first {
        field = String(first)
        qualifier = nil
    } else {
        throw FormatError.invalidFormat
    }
    switch field {
    case "message":
        return \.message
    case "level":
        return \.level.rawValue
    case "date":
        let formatter = formatters[qualifier]
        return { formatter.string(from: $0.date) }
    case "module":
        return \.module
    case "file":
        return \.file
    case "function":
        return \.function
    case "line":
        return \.line.description
    default:
        throw FormatError.unknownField(field)
    }
}

fileprivate enum ParseState {
    case none
    case openBrace(Int)
    case inBrace(String)
    case closeBrace(String, Int)
}

fileprivate enum RenderStep {
    case extract((LogEntry) -> String)
    case constant(String)
    
    func render(_ entry: LogEntry) -> String {
        switch self {
        case .extract(let extractor):
            return extractor(entry)
        case .constant(let string):
            return string
        }
    }
}

func renderer(using format: String) throws -> @Sendable (LogEntry) -> String {
    var steps: [RenderStep] = []
    var state: ParseState = .none
    for c in format {
        switch (c, state) {
        case ("{", .none):
            state = .openBrace(1)
        case ("{", .openBrace(1)):
            state = .openBrace(2)
        case ("{", _):
            throw FormatError.invalidFormat
        case ("}", .openBrace(2)):
            throw FormatError.invalidFormat
        case ("}", .inBrace(let s)):
            state = .closeBrace(s, 1)
        case ("}", .closeBrace(let s, 1)):
            let extractor = try extractor(for: s)
            steps.append(.extract(extractor))
            state = .none
        case ("}", _):
            throw FormatError.invalidFormat
        case (_, .openBrace(2)):
            state = .inBrace(String(c))
        case (_, .inBrace(let s)):
            state = .inBrace(s + String(c))
        case (_, .none):
            steps.append(.constant(String(c)))
        default:
            print("Invalid state: \(c) \(state)")
            throw FormatError.invalidFormat
        }
    }
    return { [steps] entry in
        var formatted = ""
        for step in steps {
            formatted.append(step.render(entry))
        }
        return formatted
    }
}
