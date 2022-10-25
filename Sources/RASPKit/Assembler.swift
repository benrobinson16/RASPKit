import Foundation

struct Assembler {
    func assemble(_ program: String) throws -> [Int] {
        let lines = program.components(separatedBy: "\n")
        let labelDictionary = try numberLabelledLines(lines)
        let variableDictionary = try variableDefinitions(lines)
        var outputInstructions: [Int] = []
        
        for line in lines {
            
            // Ignore variable definitions
            if line.hasPrefix("$define ") {
                continue
            }
            
            // Ignore empty lines
            if line.trimmingCharacters(in: .whitespaces).count == 0 {
                continue
            }
            
            var lineComponents = line.components(separatedBy: " ")
            
            // Remove the labelling from the line
            if line.hasPrefix("@") && line.contains(": ") {
                lineComponents.removeFirst()
            }
            
            // Identify halt expression
            if lineComponents.count == 1 {
                guard lineComponents[0] == "HLT" else {
                    throw AssemblerError.invalidExpressionsInLine
                }
                
                let halt = Instruction(.halt, .immediate, 0)
                outputInstructions.append(halt.encode())
                continue
            }
            
            guard lineComponents.count == 2 else { throw AssemblerError.invalidExpressionsInLine }
            
            // Extract the operation
            let operation = Operation.fromCharCode(lineComponents[0])
            guard let operation else { throw AssemblerError.invalidOperation }
            
            var addressingMode: AddressingMode
            var value: Int
            
            // Extract the addressing mode and value
            if lineComponents[1].hasPrefix("@") {
                let lineLabel = String(lineComponents[1].dropFirst())
                guard let lineNumber = labelDictionary[lineLabel] else { throw AssemblerError.invalidLabel }
                
                addressingMode = .immediate
                value = lineNumber
            } else {
                let newAddressingMode = AddressingMode.fromAddress(lineComponents[1])
                guard let newAddressingMode else { throw AssemblerError.invalidAddressingMode }
                addressingMode = newAddressingMode
                
                // Extract the value
                let address = String(lineComponents[1].dropFirst(addressingMode.prefix().count))
                if let intAddress = Int(address) {
                    value = intAddress
                } else if let variableAddress = variableDictionary[address] {
                    value = variableAddress
                } else {
                    throw AssemblerError.invalidValue
                }
            }
            
            // Convert to an integer
            let instruction = Instruction(operation, addressingMode, value)
            outputInstructions.append(instruction.encode())
        }
        
        return outputInstructions
    }
    
    private func numberLabelledLines(_ lines: [String]) throws -> [String: Int] {
        var labelDictionary: [String: Int] = [:]
        var index = -1
        
        for line in lines where !line.hasPrefix("$define") && !line.trimmingCharacters(in: .whitespaces).isEmpty {
            index += 1
            if !line.hasPrefix("@") { continue }
            
            let lineDefinition = line.components(separatedBy: ": ")
            guard lineDefinition.count > 1 else { throw AssemblerError.invalidLabelDefinition }
            
            let identifier = String(lineDefinition[0].dropFirst())
            labelDictionary[identifier] = index
        }
        
        return labelDictionary
    }
    
    private func variableDefinitions(_ lines: [String]) throws -> [String: Int] {
        var nextIndex = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty && !$0.hasPrefix("$define") }.count
        var variables: [String: Int] = [:]
        
        for line in lines where line.hasPrefix("$define ") {
            let components = line.components(separatedBy: " ")
            guard components.count == 2 else { throw AssemblerError.invalidVariableDefinition }
            
            variables[components[1]] = nextIndex
            nextIndex += 1
        }
        
        return variables
    }
    
    enum AssemblerError: Error {
        case invalidVariableDefinition
        case invalidLabelDefinition
        case invalidExpressionsInLine
        case invalidOperation
        case invalidAddressingMode
        case invalidVariableName
        case invalidLabel
        case invalidValue
    }
}
