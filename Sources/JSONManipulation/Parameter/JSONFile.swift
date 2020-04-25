import Foundation
import JSONKit
import Files

extension File {
    func readJSON() throws -> JSONFile {
        let data = try self.read()
        let json = try JSONDecoder().decode(JSONNode.self, from: data)
        let jsonFile = JSONFile(json: json)
        jsonFile.extra["name"] = self.nameExcludingExtension
        return jsonFile
    }
    
    func writeJSON(_ jsonFile: JSONFile) throws {
        let data = try JSONEncoder().encode(jsonFile.json)
        try write(data)
    }
}

class JSONFile {
    var extra = [String: String]()
    var json: JSONNode
    init(json: JSONNode) {
        self.json = json
    }
}
