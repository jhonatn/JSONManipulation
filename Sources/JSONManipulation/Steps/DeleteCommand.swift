import Foundation
import ConsoleKit
import Files
import JSONKit

struct Delete: StepParams {}

extension Delete: RawInputParameters {
    func process(input: StepIO, storage: ProcessorStorage) throws {
        switch input {
        case .file(let fileParams):
            let file = try storage.baseFolder.file(at: fileParams.file)
            try file.delete()
        case .folder(let folderParams):
            let folder = try storage.baseFolder.subfolder(at: folderParams.folder)
            try folder.delete()
        case .named(let namedParams):
            storage.clearNamed(namedParams.name)
        case .multiple(let steps):
            try steps.forEach {
                try process(input: $0, storage: storage)
            }
        }
    }
}
