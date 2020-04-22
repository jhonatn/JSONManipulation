import Foundation
import JSONKit
import Files

enum EnumDecodeError: Error {
    case typeNotMapped
}

enum Step: Decodable {
    case map        (BaseStepParams, Map)
    case merge      (BaseStepParams, Merge)
    case uniqueKey  (BaseStepParams, UniqueKey)
    case delete     (BaseStepParams, Delete)
    
    enum CodingKeys: CodingKey {
        case action
    }
    
    init(from decoder: Decoder) throws {
        let baseParams = try BaseStepParams(from: decoder)
        
        switch baseParams.action {
        case Map.classNameAsKey:
            self = .map(baseParams, try Map(from: decoder))
        case Merge.classNameAsKey:
            self = .merge(baseParams, try Merge(from: decoder))
        case UniqueKey.classNameAsKey:
            self = .uniqueKey(baseParams, try UniqueKey(from: decoder))
        case Delete.classNameAsKey:
            self = .delete(baseParams, try Delete(from: decoder))
        default:
            throw EnumDecodeError.typeNotMapped
        }
    }
    
    var params: (BaseStepParams, StepParams) {
        switch self {
        case .map(let step):
            return step
        case .merge(let step):
            return step
        case .uniqueKey(let step):
            return step
        case .delete(let step):
            return step
        }
    }
}

extension Decodable {
    static var classNameAsKey: String {
        let className = String(describing: Self.self)
        return className.prefix(1).lowercased() + className.dropFirst()
    }
}

protocol RawInputParameters: StepParams {
    func process(input: StepIO, storage: ProcessorStorage) throws
}

extension RawInputParameters {
    func process(optionalInput: StepIO?, storage: ProcessorStorage) throws {
        try process(input: optionalInput ?? .passthrough,
                    storage: storage)
    }
}

protocol SingleInputParameters: StepParams {
    func process(json: JSONNode) throws -> JSONNode?
}

protocol MultipleInputParameters: StepParams {
    func process(multipleJson: [JSONNode]) throws -> JSONNode?
}

protocol StepParams: Decodable {}

struct BaseStepParams: Decodable {
    let action: String
    let input: StepIO?
    let output: StepIO?
}
