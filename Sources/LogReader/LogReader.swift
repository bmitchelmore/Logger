import Foundation
import LogFoundation
import ArgumentParser

@main
struct LogReader: AsyncParsableCommand {
    @Flag(name: .customShort("t")) var watch: Bool = false
    @Option(name: .customShort("n")) var last: Int? = nil
    @Argument var log: String = "log.jsonl"
    @Argument var format: String = DefaultFormat

    mutating func run() async throws {
        let render = try BuildRenderer(using: format)
        let decoder = JSONDecoder()
        let lines = try Lines(path: log, last: last, watch: watch)
        for try await line in lines.lines {
            let entry = try decoder.decode(LogEntry.self, from: line)
            let rendered = render(entry)
            print(rendered)
        }
    }
}
