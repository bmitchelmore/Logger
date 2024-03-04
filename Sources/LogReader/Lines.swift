import Foundation
import DequeModule

enum LinesError: Error {
    case invalidPath
    case invalidFile
}

class Lines {
    private let fp: UnsafeMutablePointer<FILE>
    private let fd: Int32
    private let queue: DispatchQueue
    private let source: DispatchSourceFileSystemObject
    private var offset: Int
    private let watch: Bool
    private var continuation: AsyncStream<Data>.Continuation?
    private var buffer: (cap: Int, items: Deque<Data>)?
    
    deinit {
        source.resume()
    }
    
    init(path: String, last: Int?, watch: Bool) throws {
        guard let fp: UnsafeMutablePointer<FILE> = fopen(path, "r") else {
            throw LinesError.invalidPath
        }
        let fd: Int32 = fileno(fp)
        guard fd != -1 else {
            throw LinesError.invalidFile
        }
        self.fp = fp
        self.fd = fd
        self.queue = DispatchQueue(label: "ca.burea.readlog.lines")
        self.source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: .all,
            queue: queue
        )
        self.offset = 0
        self.watch = watch
        
        if let last = last {
            buffer = (last, Deque())
        } else {
            buffer = nil
        }
        
        guard watch else {
            return
        }
        self.source.setCancelHandler {
            
        }
        self.source.setEventHandler {
            if self.source.data.contains(.extend) {
                let result = fseek(self.fp, self.offset, SEEK_SET)
                guard result == 0 else {
                    self.finish()
                    return
                }
                while let line = self.readline() {
                    self.continuation?.yield(line)
                }
            }
        }
        self.source.resume()
    }
    
    func readline() -> Data? {
        var buffer: UnsafeMutablePointer<Int8>? = nil
        var bufferSize = 0
        let count = getline(&buffer, &bufferSize, fp)
        guard count != -1 else {
            return nil
        }
        guard let bytes = buffer else {
            return nil
        }
        let data = Data(bytesNoCopy: bytes, count: count, deallocator: .free)
        buffer = nil
        offset += count
        return data
    }

    func finish() {
        source.cancel()
        fclose(fp)
        continuation?.finish()
    }
    
    var lines: AsyncStream<Data> {
        return AsyncStream { continuation in
            self.continuation = continuation
            while let line = self.readline() {
                if var list = buffer {
                    list.items.append(line)
                    if list.items.count > list.cap {
                        _ = list.items.removeFirst()
                    }
                    buffer = (list.cap, list.items)
                } else {
                    continuation.yield(line)
                }
            }
            if let buffer = buffer {
                for line in buffer.items {
                    continuation.yield(line)
                }
            }
            guard self.watch else {
                self.finish()
                return
            }
        }
    }
}
