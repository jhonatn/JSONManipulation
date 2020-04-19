//
//  File.swift
//  
//
//  Created by everis on 4/3/20.
//

import Foundation

enum EnumDecodeError: Error {
    case typeNotMapped
}

enum ConfigurationStep: Decodable {
    case map(Map)
    case merge(Merge)
    case uniqueKey(UniqueKey)
    
    enum CodingKeys: CodingKey {
        case action
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actionName = try container.decode(String.self, forKey: .action)
        
        switch actionName {
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
    
    func execute() throws {
        switch self {
        case .map(let obj):
            try obj.execute()
        case .merge(let obj):
            try obj.execute()
        case .uniqueKey(let obj):
            try obj.execute()
        }
    }
}
