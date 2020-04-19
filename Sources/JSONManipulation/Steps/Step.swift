//
//  File.swift
//  
//
//  Created by everis on 4/19/20.
//

import Foundation
import Files

//@dynamicMemberLookup
struct ProcessedStepParameters<T> {
    let input: [File]
    let output: [File]
    let parameters: T
//    subscript<Subject>(dynamicMember: keyPath: KeyPath<T, Subject>) -> Subject {
//        T[keyPath: keyPath]
//    }
}

protocol StepParameters: Decodable {
    var inputPath: String? { get }
    var outputPath: String? { get }
}
