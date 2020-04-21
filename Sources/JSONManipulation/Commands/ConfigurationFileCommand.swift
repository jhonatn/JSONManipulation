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
        let configFile = try File(path: signature.filePath)
        guard let parentFolder = configFile.parent else {
            throw ConfigurationFileError.cantAccessConfigParentFolder
        }
        
        let yamlData = try configFile.read()
        guard let yamlString = String(data: yamlData, encoding: .utf8) else {
            throw ConfigurationFileError.cantDecodeConfiguration
        }
        let yaml: [Step]
        do {
            yaml = try YAMLDecoder().decode([Step].self,
                                            from: yamlString)
        } catch {
            throw ConfigurationFileError.badFormat
        }
        
        try Processor.process(steps: yaml, baseFolder: parentFolder)
    }
}

enum ConfigurationFileError: Error, LocalizedError {
    case cantDecodeConfiguration, badFormat, cantAccessConfigParentFolder
    
    var errorDescription: String? {
        switch self {
        case .badFormat:
            return "The configuration file is not structured as expected"
        case .cantDecodeConfiguration:
            return "The configuration file is not valid"
        case .cantAccessConfigParentFolder:
            return "Cannot access configuration file enclosing folder"
        }
    }
}
