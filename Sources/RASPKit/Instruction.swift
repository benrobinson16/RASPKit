public struct Instruction {
    public let operation: Operation
    public let addressingMode: AddressingMode
    public let value: Int
    
    public init(_ operation: Operation, _ addressingMode: AddressingMode, _ value: Int) {
        self.operation = operation
        self.addressingMode = addressingMode
        self.value = value
    }
    
    func encode() -> Int {
        return Constants.shared.encodeOpcode(operation.rawValue)
            + Constants.shared.encodeAddressingMode(addressingMode.rawValue)
            + Constants.shared.encodeValue(value)
    }
    
    static func decode(_ rawInstruction: Int) -> Instruction? {
        let operationValue = Constants.shared.extractOpcode(rawInstruction)
        let addresingValue = Constants.shared.extractAddressingMode(rawInstruction)
        let value = Constants.shared.extractValue(rawInstruction)
        
        if let operation = Operation(rawValue: operationValue),
           let addressing = AddressingMode(rawValue: addresingValue) {
            return .init(operation, addressing, value)
        }
        
        return nil
    }
}
