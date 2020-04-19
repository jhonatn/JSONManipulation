//
//  File.swift
//  
//
//  Created by everis on 4/1/20.
//

import Foundation
import ConsoleKit
import Files
import JSONKit

struct Merge: StepParameters {
    let inputPath: String?
    let outputPath: String?
}

extension Merge {
    func execute() throws {
        let searchDir = try Folder(path: sourceDirectory)
        
        let destination: File
        if let destinationFile = destinationFile {
            destination = try File(path: destinationFile)
        } else {
            var filename: UUID
            repeat {
                filename = UUID()
            } while (searchDir.containsFile(at: filename))
            destination = try searchDir.createFile(at: filename)
        }
        
        var dataToSave: JSONNode? = nil
        
        try searchDir.forEachJSONFile { file, jsonObj in
            if let oldData = dataToSave {
                dataToSave = try oldData.merge(with: jsonObj)
            } else {
                dataToSave = jsonObj
            }
        }
        
        if let data = dataToSave {
            try destination.writeJSON(data)
        } else {
            try destination.write(Data())
        }
    }
}

extension Folder {
    func createFile(at fileName: UUID) throws -> File {
        try self.createFile(at: fileName.uuidString)
    }
    func containsFile(at fileName: UUID) -> Bool {
        self.containsFile(at: fileName.uuidString)
    }
}
