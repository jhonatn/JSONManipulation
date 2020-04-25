import Foundation
import JSONKit

enum AdditionalStepIO: Decodable {
    case raw(StepIO)
    case loaded([JSONFile])
    
    init(from decoder: Decoder) throws {
        self = try .raw(StepIO(from: decoder))
    }
}

func loadAdditionalIO<T: StepParams>(obj: inout T, storage: ProcessorStorage, keyPaths: [WritableKeyPath<T, AdditionalStepIO>]) throws {
    try keyPaths.forEach { (keyPath) in
        guard case .raw(let stepIO) = obj[keyPath: keyPath] else {
            return
        }
        let data = try storage.load(stepIO)
        obj[keyPath: keyPath] = .loaded(data)
    }
}

protocol AdditionalIOContainer {
    func loadAdditionalIO(basedOn storage: ProcessorStorage) throws
}

extension StepParams {
    func loadAdditionalIO(basedOn _: ProcessorStorage) {}
    func loadAdditionalIO(_ io: AdditionalStepIO, storage: ProcessorStorage) throws -> AdditionalStepIO {
        guard case .raw(let stepIO) = io else {
            return io
        }
        let data = try storage.load(stepIO)
        return .loaded(data)
    }
}

extension AdditionalStepIO {
    var content: [JSONFile] {
        switch self {
        case .raw:
            fatalError("Programmer did a boo boo")
        case .loaded(let content):
            return content
        }
    }
}
