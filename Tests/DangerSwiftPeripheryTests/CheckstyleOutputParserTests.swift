//
//  CheckstyleOutputParserTests.swift
//  
//
//  Created by 多鹿豊 on 2022/04/11.
//

import XCTest
@testable import DangerSwiftPeriphery

final class CheckstyleOutputParserTests: XCTestCase {
    private var outputParser: CheckstyleOutputParser!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidXML() throws {
        let xmlString = """
        <?xml version="1.0" encoding="utf-8"?>
        <checkstyle version="4.3">
            <file name="/path/to/file1">
                <error line="1" column="15" severity="warning" message="test message 1"/>
                <error line="2" column="29" severity="warning" message="test message 2"/>
            </file>
            <file name="/path/to/file2">
                <error line="1" column="15" severity="warning" message="test message 3"/>
            </file>
        </checkstyle>
        """
        
        outputParser = CheckstyleOutputParser()
        do {
            let violations = try outputParser.parse(xml: xmlString, projectRootPath: "/path/to")
            
            XCTAssertEqual(violations.count, 3)
            XCTAssertEqual(violations[0].filePath, "file1")
            XCTAssertEqual(violations[0].line, 1)
            XCTAssertEqual(violations[0].message, "test message 1")
            XCTAssertEqual(violations[1].filePath, "file1")
            XCTAssertEqual(violations[1].line, 2)
            XCTAssertEqual(violations[1].message, "test message 2")
            XCTAssertEqual(violations[2].filePath, "file2")
            XCTAssertEqual(violations[2].line, 1)
            XCTAssertEqual(violations[2].message, "test message 3")
        } catch {
            XCTFail("Unexpeced error: \(error)")
        }
    }
    
    func testNoCheckstyleXML() throws {
        let xmlString = """
        <?xml version="1.0" encoding="utf-8"?>
        <test version="4.3">
            <file name="/path/to/file1">
                <error line="1" column="15" severity="warning" message="test message 1"/>
                <error line="2" column="29" severity="warning" message="test message 2"/>
            </file>
        </test>
        """
        
        outputParser = CheckstyleOutputParser()
        do {
            _ = try outputParser.parse(xml: xmlString, projectRootPath: "/path/to")
            
            XCTFail("parse must fail")
        } catch let error as CheckstyleOutputParser.Error {
            switch error {
            case .invalidCheckstyleXML:
                break
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
