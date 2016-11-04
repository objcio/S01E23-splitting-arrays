import XCTest

enum Block: Equatable {
    case code(String)
    case text(String)
    case header(String)
    // ...
}

enum PlaygroundElement: Equatable {
    case code(String)
    case documentation([Block])
}


// This is the first version with the `flush` function
func playground_flush(blocks: [Block]) -> [PlaygroundElement] {
    var result: [PlaygroundElement] = []
    var nonCodeBlocks: [Block] = []
    func flush() {
        if !nonCodeBlocks.isEmpty {
            result.append(.documentation(nonCodeBlocks))
            nonCodeBlocks = []
        }
    }
    for block in blocks {
        switch block {
        case .code(let code):
            flush()
            result.append(.code(code))
        default:
            nonCodeBlocks.append(block)
        }
    }
    flush()
    return result
}

// This is the second version which mutates the last element of the result array
func playground_mutate_last(blocks: [Block]) -> [PlaygroundElement] {
    var result: [PlaygroundElement] = []
    for block in blocks {
        if case let .code(code) = block {
            result.append(.code(code))
        } else {
            var newBlocks = [block]
            if case let .documentation(existingBlocks)? = result.last {
                result.removeLast()
                newBlocks = existingBlocks + newBlocks
            }
            result.append(.documentation(newBlocks))
        }
    }
    return result
}

// This is the final version
func playground(blocks: [Block]) -> [PlaygroundElement] {
    return blocks.reduce([]) { result, block in
        switch (block, result.last) {
        case let (.code(code), _):
            return result + [.code(code)]
        case let (_, .documentation(existing)?):
            return result.dropLast() + [.documentation(existing + [block])]
        default:
            return result + [.documentation([block])]
        }
    }
}

func AssertEqual<A: Equatable>(_ l: [A], _ r: [A], file: StaticString = #file, line: UInt = #line) {
    var message = ""
    dump(l, to: &message)
    message += "\n\nis not equal to:\n\n"
    dump(r, to: &message)
    XCTAssertEqual(l, r, message, file: file, line: line)
}

class TODOTests: XCTestCase {
    func testPlayground() {
        let sample: [Block] = [
            .code("swift sample code"),
            .header("My Header"),
            .text("Hello"),
            .code("more")
        ]
        
        let result: [PlaygroundElement] = [
            .code("swift sample code"),
            .documentation([Block.header("My Header"), Block.text("Hello")]),
            .code("more")
        ]
        AssertEqual(playground(blocks: sample), result)
    }

    func testWithoutTrailingCode() {
        let sample: [Block] = [
            .code("swift sample code"),
            .header("My Header"),
            .text("Hello")
        ]
        
        let result: [PlaygroundElement] = [
            .code("swift sample code"),
            .documentation([Block.header("My Header"), Block.text("Hello")])
        ]
        AssertEqual(playground(blocks: sample), result)
    }
}
