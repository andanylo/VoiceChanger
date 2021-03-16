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

    func testVoiceSound(){
        
        let voiceSound = VoiceSound(lastPathComponent: "test.m4a")
        XCTAssertNotNil(voiceSound.url)
    }
    
    func testDirectory(){
        let url = DirectoryManager.shared.returnRecordsDirectory()
        XCTAssertNotNil(url, "Records directory exists")
    }
   
    func testRecorder(){
        let voiceSound = VoiceSound(lastPathComponent: "test.m4a")
        
        XCTAssertNoThrow(Recorder().validateAndStart(voiceSound: voiceSound, errorHandler: { (error) in
            
        }))
    }
    func testEffects(){
        let effect1 = Effects(speed: 1, pitch: 1, distortion: 1, reverb: 1)
        let effect2 = Effects(speed: 1, pitch: 1, distortion: 1, reverb: 1)
        XCTAssertTrue(effect1.isEqual(effect2))
    }
    func testTimerLabelModel(){
        let timeLabelModel = TimerLabelModel(format: "mm:ss.MM")
        let timeComponents = TimeComponents(seconds: 32, minutes: 1, miliseconds: 450)
        
        XCTAssertEqual(timeLabelModel.returnText(from: timeComponents), "01:32.45")
    }
    func testCustomTimer(){
        let timer = CustomTimer(timeInterval: 0.001)
        timer.setCurrentTime(from: TimeComponents(seconds: 30, minutes: 1, miliseconds: 324))
        XCTAssertEqual(timer.currTime, 90324)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
