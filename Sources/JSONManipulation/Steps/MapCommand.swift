import Foundation
import ConsoleKit
import Files
import JSONKit

enum MapError: Error {
    case missingKey
    case malformedObjects
}

struct Map: StepParameters {
    let inputPath: String?
    let outputPath: String?
    var key: String?
}

extension Map {
    func execute() throws {
        let searchDir = try Folder(path: sourceDirectory)
        guard let mapKey = key else {
            throw MapError.missingKey
        }
        
        var dataToSave = [String: JSONNode]()
        
        try searchDir.forEachJSONFile { file, jsonObj in
            let newObj: JSONNode?
            if case .array(let incomingArray) = jsonObj {
                let newArray = try incomingArray.map { arrayItem -> JSONNode? in
                    if case .dict(let dict) = arrayItem {
                        return dict[mapKey]
                    } else {
                        throw MapError.missingKey
                    }
                }
                newObj = .array(newArray)
            } else if case .dict(let incomingDict) = jsonObj {
                newObj = incomingDict[mapKey]
            } else {
                throw MapError.malformedObjects
            }
            
            dataToSave[file.path] = newObj
        }
        
        try dataToSave.forEach { path, value in
            let file = try File(path: path)
            try file.writeJSON(value)
        }
    }
}

extension Decodable {
    static var classNameAsKey: String {
        let className = String(describing: Self.self)
        return className.prefix(1).lowercased() + className.dropFirst()
    }
}
