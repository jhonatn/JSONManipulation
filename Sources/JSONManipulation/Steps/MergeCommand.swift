import Foundation
import JSONKit

struct Merge: StepParams {}

extension Merge: MultipleInputParameters {
    func process(multipleJson: [JSONNode]) throws -> JSONNode? {
        var dataToSave: JSONNode? = nil
        
        try multipleJson.forEach { jsonObj in
            if let oldData = dataToSave {
                dataToSave = try oldData.merge(with: jsonObj)
            } else {
                dataToSave = jsonObj
            }
        }
        
        return dataToSave
    }
}

fileprivate extension JSONNode {
    func merge(with node: JSONNode?) throws -> JSONNode {
        guard let incomingNode = node else {
            return self
        }
        
        switch compare(to: incomingNode) {
        case .dict(let lhs, let rhs):
            return .dict(try lhs.merging(rhs) { (lhsKey, rhsKey) -> JSONNode in
                if lhsKey == rhsKey {
                    throw JSONKitError.dictionaryCollision
                } else {
                    assertionFailure("Shouldn't happen never")
                    return lhsKey
                }
            })
        case .array(let lhs, let rhs):
            return .array(lhs + rhs)
        case .string(let lhs, let rhs):
            return .string(lhs + rhs)
        case .integer(let lhs, let rhs):
            if let int = Int("\(lhs)\(rhs)") {
                return .integer(int)
            } else {
                return .number(Double.numberOrCapped(from: "\(lhs)\(rhs)"))
            }
        case .integerToDouble(let lhs, let rhs):
            let lhsAsDouble = round(Double(lhs))
            let newDouble = Double.numberOrCapped(from: "\(lhsAsDouble)\(rhs)")
            return .number(newDouble)
        case .doubleToInteger(let lhs, let rhs):
            let rhsAsDouble = round(Double(rhs))
            let newDouble = Double.numberOrCapped(from: "\(lhs)\(rhsAsDouble)")
            return .number(newDouble)
        case .number(let lhs, let rhs):
            return .number(Double.numberOrCapped(from: "\(lhs)\(rhs)"))
        case .bool:
            throw JSONKitError.cantMerge
        case .notComparable:
            throw JSONKitError.notHomogeneous
        }
    }
}

fileprivate extension Double {
    private static let maxAsString = "\(Double.greatestFiniteMagnitude)"
    private init?(_ substring: Substring) {
        self.init(String(substring))
    }
    static func numberOrCapped(from string: String) -> Double {
        if let incomingNumber = Double(string) {
            return incomingNumber
        } else if string.count > Self.maxAsString.count,
            let trimmed = Double(string.dropLast(string.count - Self.maxAsString.count)) {
            return trimmed
        } else {
            return Double.greatestFiniteMagnitude
        }
    }
}
