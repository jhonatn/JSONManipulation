import Foundation
import JSONKit

enum DifferenceError: Error {
    case cantDeduct
}

struct Difference: StepParams {}

extension Difference: MultipleInputParameters {
    func process(multipleJson: [JSONNode]) throws -> JSONNode? {
        var baseJson = multipleJson.first
        let deductables = multipleJson.dropFirst()
        try deductables.forEach { deductable in
            try baseJson?.deduct(deductable)
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
