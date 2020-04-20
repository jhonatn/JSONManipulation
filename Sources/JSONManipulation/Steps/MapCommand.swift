import Foundation
import ConsoleKit
import Files
import JSONKit

enum MapError: Error {
    case missingKey
    case malformedObjects
}

struct Map: Step {
    let inputPath: String?
    let outputPath: String?
    let outputName: String?
    
    let key: String
}

extension Map: SingleInputParameters {
    func process(json: JSONNode) throws -> JSONNode? {
        let newObj: JSONNode?
        if case .array(let incomingArray) = json {
            let newArray = try incomingArray.map { arrayItem -> JSONNode? in
                if case .dict(let dict) = arrayItem {
                    return dict[self.key]
                } else {
                    throw MapError.missingKey
                }
            }
            newObj = .array(newArray)
        } else if case .dict(let incomingDict) = json {
            newObj = incomingDict[self.key]
        } else {
            throw MapError.malformedObjects
        }
        
        return newObj
    }
}
