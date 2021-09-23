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
        let effect1 = Effects(speed: 1, pitch: 2, distortion: 3, reverb: 4, volume: 1)
        let effect2 = Effects(speed: 1, pitch: 2, distortion: 3, reverb: 4, volume: 1)
        XCTAssertTrue(effect1.isEqual(effect2))
    }
    func testTimerLabelModel(){
        let timeLabelModel = TimerLabelModel(format: "mm:ss.MM")
        let timeComponents = TimeComponents(seconds: 90.32)
        
        XCTAssertEqual(timeLabelModel.returnText(from: timeComponents), "01:32.45")
    }
    func testCustomTimer(){
        let timer = CustomTimer(timeInterval: 0.001)
        timer.currTime = 1245678
        
        XCTAssertTrue(timer.timeComponents.minutes < 60 && timer.timeComponents.seconds < 60 && timer.timeComponents.miliseconds < 1000)
    }
    
    func testEffectTransition(){
        let effect: Effects = Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0, volume: 1)
        let effectTransition = EffectTransition(effects: effect, startPoint: .custom(2/10), endPoint: .custom(7/10), fromValue: 1, transitionValue: 2, effectPartToTransition: .speed)
        effect.effectTransitions = [effectTransition]
        effectTransition.fileDuration = {
            return TimeComponents(seconds: 10)
        }
        for i in 0...10{
            effectTransition.changeEffect(currentPlayerTime: Double(i), updateInterval: 1)
        }
        XCTAssertEqual(Int(effect.currentValues.speed), 2)
    }
    
    func testExpectedEffect(){
        let effect: Effects = Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0, volume: 1)
        let effectTransition1 = EffectTransition(effects: effect, startPoint: .custom(2/10), endPoint: .custom(4/10), fromValue: 1, transitionValue: 2, effectPartToTransition: .speed)
        let effectTransition2 = EffectTransition(effects: effect, startPoint: .custom(6/10), endPoint: .custom(8/10), fromValue: 2, transitionValue: 1, effectPartToTransition: .speed)
        effect.effectTransitions = [effectTransition1, effectTransition2]
        
        [effectTransition1, effectTransition2].forEach({
            $0.fileDuration = {
                return TimeComponents(seconds: 10)
            }
        })
        let value1 = effect.expectedValue(for: .speed, at: 3) // 1.5
        let value2 = effect.expectedValue(for: .speed, at: 5) // 2.0
        let value3 = effect.expectedValue(for: .speed, at: 7) // 1.5
        let value4 = effect.expectedValue(for: .speed, at: 9) // 1
        
        XCTAssert(value1 == 1.5)
        XCTAssert(value2 == 2.0)
        XCTAssert(value3 == 1.5)
        XCTAssert(value4 == 1)
    }
    
    
    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
          
        }
    }

}
