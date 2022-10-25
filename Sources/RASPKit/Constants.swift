import Foundation

func power(base: Int, power: Int) -> Int {
    return Int(pow(Double(base), Double(power)))
}

struct Constants {
    let valueBits = 16
    let addressingModeBits = 2
    let opcodeBits = 4
    
    let operationMultiplier: Int
    let addressingModeMultiplier: Int
    
    init() {
        operationMultiplier = power(base: 2, power: valueBits + addressingModeBits)
        addressingModeMultiplier = power(base: 2, power: valueBits)
    }
    static let shared = Constants()
    
    func extractOpcode(_ input: Int) -> Int {
        return input / operationMultiplier
    }
    
    func extractAddressingMode(_ input: Int) -> Int {
        return (input % operationMultiplier) / addressingModeMultiplier
    }
    
    func extractValue(_ input: Int) -> Int {
        return input % addressingModeMultiplier
    }
    
    func encodeOpcode(_ input: Int) -> Int {
        return input * operationMultiplier
    }
    
    func encodeAddressingMode(_ input: Int) -> Int {
        return input * addressingModeMultiplier
    }
    
    func encodeValue(_ input: Int) -> Int {
        guard input < addressingModeMultiplier else { fatalError("VALUE OVERFLOW") }
        return input
    }
}
