//
//  File.swift
//  
//
//  Created by everis on 4/19/20.
//

import Foundation
import Files
import JSONKit

class Processor {
    private static let lastStepOutputKey = UUID().uuidString + "lastStepOutput" + UUID().uuidString
    
    static func processSteps(_ steps: [Step]) throws {
        var managedData = [String:[JSONNode]]()
        var dataToSave = [String:[JSONNode]]()
        
        try steps.forEach { parameters in
            // Obtaining input
            let input: [JSONNode]
            if let explicitInput = parameters.inputPath {
                input = try loadFiles(from: explicitInput)
            } else if let lastStepOutput = managedData[Self.lastStepOutputKey] {
                input = lastStepOutput
            } else {
                throw ProcessorError.stepIsMissingInput
            }
            
            // Process step
            let output: [JSONNode]
            switch parameters {
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
            managedData[Self.lastStepOutputKey] = output
            if let outputKey = parameters.outputName {
                managedData[outputKey] = output
            }
            if let outputPath = parameters.outputPath {
                dataToSave[outputPath] = output
            }
        }
        
        try dataToSave.forEach { (filePath, contentToSave) in
            let file = try File(path: filePath)
            
            // TODO: Implement saving to multiple files per step
            guard contentToSave.count == 1, let json = contentToSave.first else {
                throw ProcessorError.unsupportedMultipleFilesOutput
            }
            
            try file.writeJSON(json)
        }
        
        // Print, in case there's no defined file output
        if dataToSave.isEmpty {
            if let lastOutput = managedData[Self.lastStepOutputKey], lastOutput.count > 0 {
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
        }
    }
}

enum ProcessorError: Error {
    case stepIsMissingInput
    case unsupportedMultipleFilesOutput
    case nothingHappened
    case inputCantBeLoaded
}

func loadFiles(from path: String) throws -> [JSONNode] {
    let filesFound: [File]
    do {
        let file = try File(path: path)
        filesFound = [file]
    } catch {
        do {
            let folder = try Folder(path: path)
            filesFound = folder.files.filter { $0.extension?.lowercased() == "json" }
        } catch {
            throw ProcessorError.inputCantBeLoaded
        }
    }
    
    return try filesFound.map {
        try $0.readJSON()
    }
}
