import Foundation

public class RandomAccessMachine {
    public private(set) var registers: [Int]
    public private(set) var pc = 0
    public private(set) var acc = 0
    public private(set) var completed = false
    
    public init(numRegisters: Int = 1024) {
        self.registers = .init(repeating: 0, count: numRegisters)
    }
    
    public init(registers: [Int], numRegisters: Int = 1024) {
        self.registers = registers + .init(repeating: 0, count: numRegisters - registers.count)
    }
    
    public init(instructions: [Int], initialRegisters: [Int] = [], blankRegisters: Int = 0) {
        self.registers = instructions + initialRegisters + .init(repeating: 0, count: blankRegisters)
    }
    
    public func set(register: Int, value: Int) {
        registers[register] = value
    }
    
    public func run() {
        while !completed {
            run(instruction: registers[pc])
        }
    }
    
    private func run(instruction: Int) {
        pc += 1
        
        guard let decoded = Instruction.decode(instruction) else { fatalError("UNABLE TO DECODE INSTRUCTION ") }
        let value = unwrapValue(addressingMode: decoded.addressingMode, value: decoded.value)
        
        switch decoded.operation {
        case .halt:
            completed = true
        case .load:
            acc = value
        case .store:
            registers[value] = acc
        case .add:
            acc += value
        case .subtract:
            acc -= value
        case .and:
            acc &= value
        case .or:
            acc |= value
        case .xor:
            acc ^= value
        case .not:
            acc = ~acc
        case .shiftLeft:
            acc <<= value
        case .shiftRight:
            acc >>= value
        case .branchIfZero:
            if acc == 0 {
                pc = value
            }
        case .branchIfNegative:
            if acc < 0 {
                pc = value
            }
        case .branchIfPositive:
            if acc > 0 {
                pc = value
            }
        case .branchIfNonZero:
            if acc != 0 {
                pc = value
            }
        case .jump:
            pc = value
        }
    }
    
    private func unwrapValue(addressingMode: AddressingMode, value: Int) -> Int {
        switch addressingMode {
        case .immediate:
            return value
        case .direct:
            return registers[value]
        case .indirect:
            return registers[registers[value]]
        }
    }
}
