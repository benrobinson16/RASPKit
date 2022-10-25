public enum AddressingMode: Int, CaseIterable {
    case immediate = 0
    case direct = 1
    case indirect = 2
    
    func prefix() -> String {
        switch self {
        case .immediate: return "#"
        case .direct: return "R"
        case .indirect: return "RR"
        }
    }
    
    func moreIndirect() -> AddressingMode? {
        switch self {
        case .immediate: return .direct
        case .direct: return .indirect
        case .indirect: return nil
        }
    }
    
    func moreDirect() -> AddressingMode? {
        switch self {
        case .immediate: return nil
        case .direct: return .immediate
        case .indirect: return .direct
        }
    }
    
    static func fromAddress(_ address: String) -> AddressingMode? {
        if address.hasPrefix("#") {
            return .immediate
        } else if address.hasPrefix("RR") {
            return .indirect
        } else if address.hasPrefix("R") {
            return .direct
        }
        
        return nil
    }
}
