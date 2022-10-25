public enum Operation: Int, CaseIterable {
    case halt = 0
    case load = 1
    case store = 2
    case add = 3
    case subtract = 4
    case and = 5
    case or = 6
    case xor = 7
    case not = 8
    case shiftLeft = 9
    case shiftRight = 10
    case branchIfZero = 11
    case branchIfNegative = 12
    case branchIfPositive = 13
    case branchIfNonZero = 14
    case jump = 15
    
    func charCode() -> String {
        switch self {
        case .halt: return "HLT"
        case .load: return "LDA"
        case .store: return "STR"
        case .add: return "ADD"
        case .subtract: return "SUB"
        case .and: return "AND"
        case .or: return "ORR"
        case .xor: return "XOR"
        case .not: return "NOT"
        case .shiftLeft: return "LSL"
        case .shiftRight: return "LSR"
        case .branchIfZero: return "BZE"
        case .branchIfNegative: return "BNE"
        case .branchIfPositive: return "BPO"
        case .branchIfNonZero: return "BNZ"
        case .jump: return "JMP"
        }
    }
    
    static func fromCharCode(_ charCode: String) -> Operation? {
        switch charCode {
        case "HLT": return .halt
        case "LDA": return .load
        case "STR": return .store
        case "ADD": return .add
        case "SUB": return .subtract
        case "ORR": return .or
        case "XOR": return .xor
        case "NOT": return .not
        case "LSL": return .shiftLeft
        case "LSR": return .shiftRight
        case "BZE": return .branchIfZero
        case "BNE": return .branchIfNegative
        case "BPO": return .branchIfPositive
        case "BNZ": return .branchIfNonZero
        case "JMP": return .jump
        default: return nil
        }
    }
}
