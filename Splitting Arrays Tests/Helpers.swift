import Foundation


func ==(lhs: Block, rhs: Block) -> Bool {
    switch (lhs, rhs) {
    case let (.code(l), .code(r)): return l == r
    case let (.text(l), .text(r)): return l == r
    case let (.header(l), .header(r)): return l == r
    default: return false
    }
}

func ==(lhs: PlaygroundElement, rhs: PlaygroundElement) -> Bool {
    switch (lhs, rhs) {
    case let (.code(l), .code(r)): return l == r
    case let (.documentation(l), .documentation(r)): return l == r
    default: return false
    }
}

