import Foundation

enum StepIOError: Error {
    case cantParseStepIO
}

struct FileStepIO: Decodable {
    let file: String
}

struct FolderStepIO: Decodable {
    let folder: String
    let filter: String?
}

struct NamedStepIO: Decodable {
    let name: String
}

enum StepIO {
    case file(FileStepIO)
    case folder(FolderStepIO)
    case named(NamedStepIO)
    
    case multiple([StepIO])
}

extension StepIO: Decodable {
    init(from decoder: Decoder) throws {
        if let array = try? [StepIO](from: decoder) {
            self = .multiple(array)
        } else if let fileIO = try? FileStepIO(from: decoder) {
            self = .file(fileIO)
        } else if let folderIO = try? FolderStepIO(from: decoder) {
            self = .folder(folderIO)
        } else if let namedIO = try? NamedStepIO(from: decoder) {
            self = .named(namedIO)
        } else {
            throw StepIOError.cantParseStepIO
        }
    }
}
