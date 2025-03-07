//
//  ProjectDataSource.swift
//
//
//  Created by Manuel Rodriguez Sebastian on 20/2/23.
//

import Foundation

internal class ProjectDataSourceImp: ProjectDataSource {
    private let parameters: Parameters
    private let configuration: Configuration
    
    private let filesDataSource: FilesDataSource = FilesDataSourceImp()
    
    internal init(parameters: Parameters, configuration: Configuration) {
        self.parameters = parameters
        self.configuration = configuration
    }
    
    func fetchLocalizables() async throws -> Set<String> {
        return try await withThrowingTaskGroup(of: Set<String>.self) { taskGroup in
            self.parameters.searchPaths.forEach { searchablePath in
                taskGroup.addTask {
                    return try await self.fetchLocalizableKeys(
                        fromPath: searchablePath,
                        extensions: self.configuration.formatsSupported,
                        enconding: self.configuration.fileEncoding,
                        pattern: self.configuration.capturePattern
                    )
                }
            }
            
            var localizablesSearched = Set<String>()
            for try await localizablesResult in taskGroup {
                localizablesSearched = localizablesSearched.union(localizablesResult)
            }
            
            return localizablesSearched
        }
    }
    
    private func fetchLocalizableKeys(fromPath path: String, extensions: Set<String>, enconding: String.Encoding, pattern: String) async throws -> Set<String> {
        return try await withThrowingTaskGroup(of: Set<String>.self) { taskGroup in
            let files = try filesDataSource.fetchRecursiveFiles(fromPath: path, extensions: extensions)
            
            files.forEach { file in
                taskGroup.addTask {
                    return try await self.searchLocalizables(atFilePath: file)
                }
            }
            
            var fileLocalizables = Set<String>()
            for try await localizables in taskGroup {
                fileLocalizables = fileLocalizables.union(localizables)
            }
            
            return fileLocalizables
        }
    }
    
    private func searchLocalizables(atFilePath filePath: String) async throws -> Set<String> {
        let fileContent = try filesDataSource.fetchFileContent(
            fromPath: filePath,
            encoding: configuration.fileEncoding
        )
        
        let fileRange = NSRange(fileContent.startIndex..<fileContent.endIndex, in: fileContent)
        let captureRegex = try NSRegularExpression(
            pattern: configuration.capturePattern,
            options: .caseInsensitive
        )
        
        let matches = captureRegex.matches(in: fileContent, range: fileRange)
        
        var results = Set<String>()
        matches.forEach { match in
            for rangeIndex in 1..<match.numberOfRanges {
                let matchRange = match.range(at: rangeIndex)
                
                if matchRange == fileRange { continue }
                
                if let substringRange = Range(matchRange, in: fileContent) {
                    let capture = String(fileContent[substringRange])
                    results.insert(capture)
                }
            }
        }
        
        return results
    }
}
