//
//  PeripheryScanCommandBuilderTests.swift
//  
//
//  Created by 多鹿豊 on 2022/04/09.
//

import XCTest
@testable import DangerSwiftPeriphery

final class PeripheryScanCommandBuilderTests: XCTestCase {
    private var scanCommandBuilder: PeripheryScanCommandBuilder!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerihperyPath() throws {
        scanCommandBuilder = PeripheryScanCommandBuilder(peripheryPath: "test/path/to/periphery", additionalArguments: [])
        
        XCTAssertEqual(scanCommandBuilder.command, "test/path/to/periphery scan --format checkstyle --quiet --disable-update-check")
    }
    
    func testAdditionalArgumantsNoOverride() throws {
        scanCommandBuilder = PeripheryScanCommandBuilder(peripheryPath: "periphery", additionalArguments: ["--test-arg1", "--test-arg2 value"])
        
        XCTAssertEqual(scanCommandBuilder.command, "periphery scan --test-arg1 --test-arg2 value --format checkstyle --quiet --disable-update-check")
    }
    
    func testAdditionalArgumantsOverride() throws {
        scanCommandBuilder = PeripheryScanCommandBuilder(peripheryPath: "periphery", additionalArguments: ["--format json"])
        
        XCTAssertEqual(scanCommandBuilder.command, "periphery scan --format checkstyle --quiet --disable-update-check")
    }
    
    func testAdditionalArgumantsDuplicate() throws {
        scanCommandBuilder = PeripheryScanCommandBuilder(peripheryPath: "periphery", additionalArguments: ["--quiet", "--disable-update-check"])
        
        XCTAssertEqual(scanCommandBuilder.command, "periphery scan --format checkstyle --quiet --disable-update-check")
    }
}
