//
//  Variables.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 17.03.2021.
//

import Foundation
class Variables{
    static let shared = Variables()
    
    var recordList: RecordList = RecordList()
    
    var currentDeviceTheme: DeviceTheme = .normal
}
