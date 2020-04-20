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

enum DecodableStep: Decodable {
    case map(Map)
    case merge(Merge)
    case uniqueKey(UniqueKey)
    
    enum CodingKeys: CodingKey {
        case action
    }
    
    init(from decoder: Decoder) throws {
        let baseParams = try BaseStepParameters(from: decoder)
        
        switch baseParams.name {
        case Map.classNameAsKey:
            self = .map(try Map(from: decoder))
        case Merge.classNameAsKey:
            self = .merge(try Merge(from: decoder))
        case UniqueKey.classNameAsKey:
            self = .uniqueKey(try UniqueKey(from: decoder))
        default:
            throw EnumDecodeError.typeNotMapped
        }
    }
    
    var rawStep: Step {
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

protocol SingleInputParameters: Step {
    func process(json: JSONNode) throws -> JSONNode?
}

protocol MultipleInputParameters: Step {
    func process(multipleJson: [JSONNode]) throws -> JSONNode?
}

protocol Step: Decodable {
    var inputPath: String? { get }
    var outputPath: String? { get }
    var outputName: String? { get }
}

struct BaseStepParameters: Decodable {
    var name: String
    var inputPath: String?
    var outputPath: String?
    var outputName: String?
}
