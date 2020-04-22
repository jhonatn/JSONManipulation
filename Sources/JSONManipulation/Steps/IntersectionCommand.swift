//import Foundation
import JSONKit

enum IntersectionError: Error {
    case cantIntersect
}

struct Intersection: StepParams {}

extension Intersection: MultipleInputParameters {
    func process(multipleJson: [JSONNode]) throws -> JSONNode? {
        var baseJson = multipleJson.first
        let deductables = multipleJson.dropFirst()
        try deductables.forEach { deductable in
            try baseJson?.filterToIntersection(with: deductable)
        }
        return baseJson
    }
}

fileprivate extension JSONNode {
    mutating func filterToIntersection(with rhs: JSONNode?) throws {
        guard let incoming = rhs else {
            return
        }
        
        switch compare(to: incoming) {
        case .dict(let lhs, let rhs):
            self = .dict(
                lhs.filter { (key, value) -> Bool in
                    rhs[key] == value
                }
            )
        case .array(let lhs, let rhs):
            self = .array(lhs.filter{
                rhs.contains($0)
            })
        case .integer(let lhs, let rhs):
            self = .integer(min(lhs, rhs))
        case .integerToDouble(let lhs, let rhs):
            self = .number(min(Double(lhs).rounded(), rhs))
        case .doubleToInteger(let lhs, let rhs):
            self = .number(min(lhs, (Double(rhs).rounded())))
        case .number(let lhs, let rhs):
            self = .number(min(lhs, rhs))
        case .string:
            throw IntersectionError.cantIntersect
        case .bool:
            throw IntersectionError.cantIntersect
        case .notComparable:
            throw IntersectionError.cantIntersect
        }
    }
}

