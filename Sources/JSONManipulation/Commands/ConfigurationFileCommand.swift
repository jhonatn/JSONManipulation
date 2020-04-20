//
//  File.swift
//  
//
//  Created by everis on 4/3/20.
//

import Foundation
import ConsoleKit
import Files
import Yams

class ConfigurationFileCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "path")
        var filePath: String
    }
    
    var help: String {
        "Run multiple commands through a configuration file"
    }
    
    func run(using context: CommandContext, signature: Signature) throws {
        let file = try File(path: signature.filePath)
        let yamlData = try file.read()
        guard let yamlString = String(data: yamlData, encoding: .utf8) else {
            throw ConfigurationFileError.cantDecodeConfiguration
        }
        let yaml: [Step]
        do {
            let decoded = try YAMLDecoder().decode([DecodableStep].self,
                                                   from: yamlString)
            yaml = decoded.map { $0.rawStep }
        } catch {
            throw ConfigurationFileError.badFormat
        }
        
        try Processor.processSteps(yaml)
    }
}

enum ConfigurationFileError: Error, LocalizedError {
    case cantDecodeConfiguration, badFormat
    
    var errorDescription: String? {
        switch self {
        case .badFormat:
            return "The configuration file is not structured as expected"
        case .cantDecodeConfiguration:
            return "The configuration file is not valid"
        }
    }
}
