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

struct Merge: StepParams {}

extension Merge: MultipleInputParameters {
    func process(multipleJson: [JSONNode]) throws -> JSONNode? {
        var dataToSave: JSONNode? = nil
        
        try multipleJson.forEach { jsonObj in
            if let oldData = dataToSave {
                dataToSave = try oldData.merge(with: jsonObj)
            } else {
                dataToSave = jsonObj
            }
        }
        
        return dataToSave
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
