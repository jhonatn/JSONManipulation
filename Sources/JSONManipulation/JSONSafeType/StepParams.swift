//
//  File.swift
//  
//
//  Created by everis on 4/3/20.
//

import Foundation
import JSONKit

enum EnumDecodeError: Error {
    case typeNotMapped
}

enum Step: Decodable {
    case map        (BaseStepParams, Map)
    case merge      (BaseStepParams, Merge)
    case uniqueKey  (BaseStepParams, UniqueKey)
    
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
        }
    }
}

extension Decodable {
    static var classNameAsKey: String {
        let className = String(describing: Self.self)
        return className.prefix(1).lowercased() + className.dropFirst()
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
    let inputPath: String?
    let outputPath: String?
    let outputName: String?
    let whitelist: String?
}
