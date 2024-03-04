import Foundation
import os

enum FormatError: Error {
    case invalidFormat
    case unknownField(String)
}

public let DefaultFormat = "[{{date}}] {{level}} /{{module}}/{{file}}@{{function}}:{{line}} {{message}}"

let dateFormatters = DateFormatterStorage()
let levelFormatters = LevelFormatterStorage()
func extractor(for property: String) throws -> (LogEntry) -> String {
    let parts = property.split(separator: "|", maxSplits: 1)
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
        let formatter = levelFormatters[qualifier]
        return { formatter.string(from: $0.level) }
    case "date":
        let formatter = dateFormatters[qualifier]
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

public func BuildRenderer(using format: String) throws -> @Sendable (LogEntry) -> String {
    var steps: [RenderStep] = []
    var state: ParseState = .none
    for c in format {
        switch (c, state) {
        case ("{", .none):
            state = .openBrace(1)
        case ("{", .openBrace(1)):
            state = .openBrace(2)
        case ("{", .openBrace(2)):
            steps.append(.constant("{"))
            state = .openBrace(2)
        case ("{", .inBrace(let string)):
            steps.append(.constant("{{\(string){"))
            state = .none
        case ("{", .closeBrace(let string, let count)):
            steps.append(.constant("{{\(string)\(String(repeating: "}", count: count))"))
            state = .none
        case ("}", .none):
            steps.append(.constant("}"))
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
        case (_, .openBrace(1)):
            steps.append(.constant("{\(c)"))
            state = .none
        default:
            print("Invalid state: \(c) \(state)")
            throw FormatError.invalidFormat
        }
    }
    switch state {
    case .none:
        break
    case .openBrace(let count):
        steps.append(.constant(String(repeating: "{", count: count)))
    case .inBrace(let string):
        steps.append(.constant("{{\(string)"))
    case .closeBrace(let string, let count):
        steps.append(.constant("{{\(string)\(String(repeating: "}", count: count))"))
    }
    return { [steps] entry in
        var formatted = ""
        for step in steps {
            formatted.append(step.render(entry))
        }
        return formatted
    }
}
