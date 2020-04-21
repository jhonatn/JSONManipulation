import Foundation
import ConsoleKit
import Files
import JSONKit

struct Delete: StepParams {}

extension Delete: RawInputParameters {
    func process(fileOrFolder: FileOrFolder) throws {
        switch fileOrFolder {
        case .file(let file):
            try file.delete()
        case.folder(let folder):
            try folder.delete()
        }
    }
}
