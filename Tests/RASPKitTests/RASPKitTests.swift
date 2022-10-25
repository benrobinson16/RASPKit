import XCTest
@testable import RASPKit

final class RASPKitTests: XCTestCase {
    let machineCodeMultiply: [Instruction] = [
        .init(.load, .direct, 13),
        .init(.branchIfZero, .immediate, 12),
        .init(.load, .direct, 14),
        .init(.branchIfZero, .immediate, 12),
        .init(.load, .direct, 15),
        .init(.add, .direct, 13),
        .init(.store, .immediate, 15),
        .init(.load, .direct, 14),
        .init(.subtract, .immediate, 1),
        .init(.store, .immediate, 14),
        .init(.branchIfZero, .immediate, 12),
        .init(.jump, .immediate, 4),
        .init(.halt, .immediate, 0)
    ]

    let assemblyLanguageMultiply = """
    $define numA
    $define numB
    $define output

    LDA RnumA
    BZE @final
    LDA RnumB
    BZE @final
    @loop: LDA Routput
    ADD RnumA
    STR #output
    LDA RnumB
    SUB #1
    STR #numB
    BZE @final
    JMP @loop
    @final: HLT
    """
    
    func testMachineCode() {
        let instructions = machineCodeMultiply.map { $0.encode() }
        
        for _ in 0..<100 {
            let a = Int.random(in: 0...100)
            let b = Int.random(in: 0...100)
            let machine = RandomAccessMachine(instructions: instructions, initialRegisters: [a, b, 0])
            machine.run()
            XCTAssertEqual(machine.registers.last, a * b)
            print("\(a) * \(b) = \(machine.registers.last!)")
        }
    }
    
    func testAssembledCode() throws {
        let assembler = Assembler()
        let instructions = try assembler.assemble(assemblyLanguageMultiply)
        
        for _ in 0..<100 {
            let a = Int.random(in: 0...100)
            let b = Int.random(in: 0...100)
            let machine = RandomAccessMachine(instructions: instructions, initialRegisters: [a, b, 0])
            machine.run()
            XCTAssertEqual(machine.registers.last, a * b)
            print("\(a) * \(b) = \(machine.registers.last!)")
        }
    }
}
