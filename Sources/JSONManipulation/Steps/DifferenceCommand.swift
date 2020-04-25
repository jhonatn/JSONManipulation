import Foundation
import JSONKit

enum DifferenceError: Error {
    case cantDeduct
    case noContent
}

struct Difference: StepParams {
    private(set) var inputToBeDeducted: AdditionalStepIO
    mutating func loadAdditionalIO(basedOn storage: ProcessorStorage) throws {
        inputToBeDeducted = try loadAdditionalIO(inputToBeDeducted, storage: storage)
    }
}

extension Difference: SingleInputParameters {
    func process(json: JSONNode) throws -> JSONNode {
        var baseJson = json
        
        try inputToBeDeducted.content.forEach { deductable in
            try baseJson.deduct(deductable.json)
        }
        
        return baseJson
    }
}

fileprivate extension JSONNode {
    mutating func deduct(_ rhs: JSONNode?) throws {
        guard let incoming = rhs else {
            return
        }
        
        switch compare(to: incoming) {
        case .dict(var lhs, let rhs):
            rhs.forEach { (key, value) in
                if lhs[key] == value {
                    lhs[key] = nil
                }
            }
            self = .dict(lhs)
        case .array(var lhs, let rhs):
            lhs.removeAll { json -> Bool in
                rhs.contains(json)
            }
            self = .array(lhs)
        case .string(var lhs, let rhs):
            if let rangeFound = lhs.range(of: rhs) {
                lhs.removeSubrange(rangeFound)
            }
            self = .string(lhs)
        case .bool:
            throw DifferenceError.cantDeduct
        case .integer(let lhs, let rhs):
            self = .integer(lhs - rhs)
        case .integerToDouble(let lhs, let rhs):
            self = .number(round(Double(lhs)) - rhs)
        case .doubleToInteger(let lhs, let rhs):
            self = .number(lhs - round(Double(rhs)))
        case .number(let lhs, let rhs):
            self = .number(lhs - rhs)
        case .notComparable:
            throw DifferenceError.cantDeduct
        }
    }
}
