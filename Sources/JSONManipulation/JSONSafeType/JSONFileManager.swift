//
//  File.swift
//  
//
//  Created by everis on 4/1/20.
//

import Foundation
import Files
import JSONKit

extension Folder {
    func forEachJSONFile (_ handler: (File, JSONNode) throws -> Void) throws {
        try files.forEach { file in
            guard file.extension?.lowercased() == "json" else {
                return
            }
            
            let jsonObj = try file.readJSON()
            try handler(file, jsonObj)
        }
    }
}

extension File {
    func writeJSON(_ json: JSONNode) throws {
        let data = try JSONEncoder().encode(json)
        try write(data)
    }
    
    func readJSON() throws -> JSONNode {
        let data = try self.read()
        return try JSONDecoder().decode(JSONNode.self, from: data)
    }
    
    func editJSON(_ handler: (JSONNode) throws -> JSONNode) throws {
        let json = try readJSON()
        let newJson = try handler(json)
        try writeJSON(newJson)
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
