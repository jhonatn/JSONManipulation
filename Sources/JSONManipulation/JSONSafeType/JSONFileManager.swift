import Foundation
import Files
import JSONKit

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
