//
//  DangerPeriphery.swift
//  
//
//  Created by 多鹿豊 on 2022/03/31.
//

import Danger

public struct DangerPeriphery {
    public static func scan(peripheryPath: String = "periphery",
                            arguments: [String] = []) {
        // make dependencies
        let commandBuilder = PeripheryScanCommandBuilder(peripheryPath: peripheryPath,
                                                         additionalArguments: arguments)
        let scanExecutor = PeripheryScanExecutor(commandBuilder: commandBuilder)
        let diffProvider = PullRequestDiffProvider(dangerDSL: Danger())
        
        // execute scan
        let result = self.scan(scanExecutor: scanExecutor,
                               currentPathProvider: DefaultCurrentPathProvider(),
                               outputParser: CheckstyleOutputParser(),
                               diffProvider: diffProvider)
        
        // handle scan result
        switch result {
        case .success(let violations):
            for violation in violations {
                warn(message: violation.message,
                     file: violation.filePath,
                     line: violation.line)
            }
        case .failure(let error):
            fail(error.localizedDescription)
        }
    }
    
    static func scan<PSE: PeripheryScanExecutable,
                     CPP: CurrentPathProvider,
                     OP: CheckstyleOutputParsable,
                     DP: PullRequestDiffProvidable>(
                        scanExecutor: PSE,
                        currentPathProvider: CPP,
                        outputParser: OP,
                        diffProvider: DP) -> Result<[Violation], Error> {
        do {
            let output = try scanExecutor.execute()
            let allViolations = try outputParser.parse(xml: output,
                                                       projectRootPath: currentPathProvider.currentPath)
            let violationsForComment = allViolations.filter({ violation -> Bool in
                let result = diffProvider.diff(forFile: violation.filePath)
                guard let changes = try? result.get() else {
                    return false
                }
                // comment only `Created files` and `Files that have been modified and are contained within hunk`
                switch changes {
                case .created:
                    return true
                case .deleted:
                    return false
                case let .modified(hunks):
                    return hunks.contains(where: {
                        let lineRange = ($0.newLineStart ..< $0.newLineSpan - $0.newLineStart)
                        if lineRange.contains(violation.line) {
                            return true
                        }
                        return false
                    })
                case .renamed:
                    return false
                }
            })
            return .success(violationsForComment)
        } catch {
            return .failure(error)
        }
    }
}
