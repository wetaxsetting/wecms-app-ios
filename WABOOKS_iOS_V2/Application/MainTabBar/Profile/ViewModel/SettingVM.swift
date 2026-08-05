//
//  SettingVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Thea Chum on 15/1/21.
//

import Foundation

class SettingVM {
    
    private var settingsRequest: WABOOKS_MREC_C001.REQUEST!
    
    var settingsResponse: WABOOKS_MREC_R004.RESPONSE? {
        didSet {
            guard let settings = settingsResponse else { return }
            self.settingsRequest = WABOOKS_MREC_C001.REQUEST(settings)
        }
    }
    
    func fetchInputSettings(shouldShowLoading: Bool = true, completion: @escaping (Swift.Result<WABOOKS_MREC_R004.RESPONSE, NSError>) -> Void) {
        DataAccess.shared.fetchData(shouldShowLoading: shouldShowLoading,
            apiKey      : APIKey.WABOOKS_MREC_R004,
            body        : WABOOKS_MREC_R004.REQUEST(),
            responseType: WABOOKS_MREC_R004.RESPONSE.self) { (result) in
                
                switch result {
                case .success(let data):
                    
                    self.settingsResponse = data
                    completion(.success(data))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    
    

}


extension UIViewController {
    
    ///Get Current App Version
    ///Return: String
    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
