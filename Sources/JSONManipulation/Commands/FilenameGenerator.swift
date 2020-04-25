import Foundation

enum FilenameGeneratorError: Error {
    case cantFindTokenValue
    case malformedFormat
}

class FilenameGenerator {
    static func generate(for jsonFile: JSONFile, basedOn format: String?) throws -> String {
        guard let originName = jsonFile.extra["name"] else {
            throw ProcessorStorageError.cantGenerateFileName
        }
        guard let format = format else {
            return originName + ".generated"
        }
        var newName = format
        let tags = try TagParser.parseTokens(in: format)
        try tags.forEach { range in
            let token: String = {
                var substring = newName[range]
                substring = substring.dropFirst().dropLast()
                return String(substring)
            }()
            guard let tokenValue = jsonFile.extra[token] else {
                throw FilenameGeneratorError.cantFindTokenValue
            }
            newName.replaceSubrange(range, with: tokenValue)
        }
        return newName
    }
}

class TagParser {
    enum Token: Character {
        case escaping = "\\"
        case replacing = "$"
    }
    
    static func parseTokens(in format: String) throws -> [ClosedRange<String.Index>] {
        var disableNextToken = false
        var openTokens = [String.Index]()
        var completeTokens = [ClosedRange<String.Index>]()
        format.indices.forEach { rawIndex in
            let rawChar = format[rawIndex]
            
            guard let char = Token(rawValue: rawChar),
                let index = rawIndex.samePosition(in: format),
                !disableNextToken
                else
            {
                disableNextToken = false
                return
            }
            
            switch char {
            case .escaping:
                disableNextToken = true
            case .replacing:
                if let startingToken = openTokens.first {
                    _ = openTokens.dropFirst()
                    completeTokens.append(startingToken...index)
                } else {
                    openTokens.insert(index, at: 0)
                }
            }
        }
        
        if openTokens.count > 0 {
            throw FilenameGeneratorError.malformedFormat
        }
        
        return completeTokens.reversed()
    }
}
