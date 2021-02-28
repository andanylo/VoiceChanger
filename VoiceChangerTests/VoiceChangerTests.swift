//
//  VoiceChangerTests.swift
//  VoiceChangerTests
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import XCTest
@testable import VoiceChanger

class VoiceChangerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testErrors(){
        
        XCTAssertThrowsError(Recorder().validateAndStart(name: "name"))
    }
    
    func testDirectory(){
        let url = DirectoryManager.shared.returnRecordsDirectory()
        XCTAssertNotNil(url, "Records directory exists")
    }
   

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
