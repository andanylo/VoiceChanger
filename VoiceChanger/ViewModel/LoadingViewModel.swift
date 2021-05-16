//
//  LoadingViewModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 10.05.2021.
//

import Foundation
class LoadingViewModel{
    
    var state: LoadingState = .loading{
        didSet{
            
            stateChangeHandler?(state)
        }
    }
    
    var stateChangeHandler: ((LoadingState) -> Void)?
    
    var currentImageName: String?{
        get{
            switch state{
            case .loading:
                return nil
            case .loadedSuccessfully:
                return "success"
            case .error:
                return "error"
            }
        }
    }
    
    
    enum LoadingState{
        case loading
        case loadedSuccessfully
        case error
    }
}
