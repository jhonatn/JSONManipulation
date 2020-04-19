import Foundation
import ConsoleKit
import Files
import JSONKit

enum UniqueKeyError: Error {
    case notAnArray
}

struct UniqueKey: StepParameters {
    let inputPath: String?
    let outputPath: String?
}

extension ProcessedStepParameters<UniqueKey> {
    func execute() throws {
        let file = try File(path: sourceFile)
        
        try file.editJSON { json in
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
}
