import Foundation
import Files
import JSONKit

class Processor {
    static func process(steps: [Step], baseFolder: Folder) throws {
        let storage = ProcessorStorage(baseFolder: baseFolder)
        
        try steps.forEach { step in
            let (baseParams, stepParams) = step.params
            
            if let rawParams = stepParams as? RawInputParameters {
                try rawParams.process(optionalInput: baseParams.input,
                                      storage: storage)
                return
            }
            
            let input = try storage.load(baseParams.input)
            
            // Process step
            let output: [JSONNode]
            switch stepParams {
            case let sip as SingleInputParameters:
                output = try input.compactMap { (data) in
                    try sip.process(json: data)
                }
            case let mip as MultipleInputParameters:
                output = try [mip.process(multipleJson: input)].compactMap { $0 }
            default:
                fatalError("Programmer did a boo boo")
            }
            
            // Save results
            try storage.save(baseParams.output,
                             jsonContent: output)
        }
        
        let writeableData = try storage.flushWriteable()
        if writeableData.isEmpty {
            // Print, in case there's no defined file output
            if let lastOutput = try? storage.load(.passthrough), lastOutput.count > 0 {
                try lastOutput.enumerated().forEach { offset, json in
                    if offset > 0 {
                        print("")
                    }
                    let asData = try JSONEncoder().encode(json)
                    print(String(data: asData, encoding: .utf8)!)
                }
            } else {
                throw ProcessorError.nothingHappened
            }
        } else {
            try writeableData.forEach { (file, json) in
                try file.writeJSON(json)
            }
        }
    }
}

enum ProcessorError: Error {
    case nothingHappened
}
