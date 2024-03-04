import Foundation

protocol LevelFormatter {
    func string(from level: LogLevel) -> String
}

struct BasicLevelFormatter: LevelFormatter, Sendable {
    enum Prefix: String {
        case plain
        case hashtag
        
        static var `default`: Self = .hashtag
    }
    enum Casing: String {
        case upper
        case lower
        case cap
        
        static var `default`: Self = .upper
    }
    enum Coloring: String {
        case mono
        case ansi
        
        static var `default`: Self = .mono
    }
    enum Colors: Int {
        case black = 30
        case red = 31
        case green = 32
        case yellow = 33
        case blue = 34
        case magenta = 35
        case cyan = 36
        case white = 37
        case reset = 0
        
        var ansi: String {
            return "\u{001B}[0;\(rawValue)m"
        }
    }
    
    private let prefix: Prefix
    private let casing: Casing
    private let coloring: Coloring
    
    init(prefix: Prefix, casing: Casing, coloring: Coloring) {
        self.prefix = prefix
        self.casing = casing
        self.coloring = coloring
    }
    
    func string(from item: LogLevel) -> String {
        var prefix: String
        switch self.prefix {
        case .plain:
            prefix = ""
        case .hashtag:
            prefix = "#"
        }
        let label: String
        switch casing {
        case .upper:
            label = item.rawValue.uppercased()
        case .lower:
            label = item.rawValue.lowercased()
        case .cap:
            label = item.rawValue.capitalized
        }
        let string = "\(prefix)\(label)"
        switch coloring {
        case .mono:
            return string
        case .ansi:
            let color: Colors
            switch item {
            case .debug:
                color = .green
            case .info:
                color = .green
            case .warn:
                color = .yellow
            case .error:
                color = .red
            case .fatal:
                color = .red
            }
            return "\(color.ansi)\(string)\(Colors.reset.ansi)"
        }
    }
}

func BuildLevelFormatter(for identifier: String?) -> any LevelFormatter {
    guard let identifier = identifier else {
        return BasicLevelFormatter(prefix: .default, casing: .default, coloring: .default)
    }
    
    typealias Prefix = BasicLevelFormatter.Prefix
    typealias Casing = BasicLevelFormatter.Casing
    typealias Coloring = BasicLevelFormatter.Coloring
    let parts = identifier.split(separator: "|", maxSplits: 2)
    var _prefix: Prefix?
    var _casing: Casing?
    var _coloring: Coloring?
    for part in parts {
        let part = String(part)
        if let value = Prefix(rawValue: part), _prefix == nil {
            _prefix = value
        } else if let value = Casing(rawValue: part), _casing == nil {
            _casing = value
        } else if let value = Coloring(rawValue: part), _coloring == nil {
            _coloring = value
        }
    }
    let prefix = _prefix ?? .default
    let casing = _casing ?? .default
    let coloring = _coloring ?? .default
    
    return BasicLevelFormatter(prefix: prefix, casing: casing, coloring: coloring)
}
