import Foundation
import ConsoleKit
import Files
import JSONKit

enum UniqueKeyError: Error {
    case notAnArray
}

struct UniqueKey: Step {
    let inputPath: String?
    let outputPath: String?
    let outputName: String?
}

extension UniqueKey: SingleInputParameters {
    func process(json: JSONNode) throws -> JSONNode? {
        guard case .array(let array) = json else {
            throw UniqueKeyError.notAnArray
        }

        var addedDict = [JSONNode: Bool]()
        return .array (
            array
                .compactMap { $0 }
                .filter {
                    addedDict.updateValue(true, forKey: $0) == nil
                }
        )
    }
}
