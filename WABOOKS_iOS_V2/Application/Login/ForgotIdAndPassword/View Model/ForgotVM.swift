//
//  Forgot.swift
//  WABOOKS_iOS_V2
//
//  Created by Bung on 5/20/21.
//

import Foundation

class ForgotVM {
    
    // Send Phone Number Forgot ID
    func requestSendPhoneNumber(vcType: VCType, USER_NM: String, CLPH_NO: String, completion: @escaping (Swift.Result<WABOOKS_MREC_MBMR_0002_R001.RESPONSE?, NSError>) -> Void) {

        let requestBody = WABOOKS_MREC_MBMR_0002_R001.REQUEST(USER_NM: USER_NM, CLPH_NO: CLPH_NO)

        DataAccess.shared.fetchData(apiKey: vcType == .ForgetID ? .WABOOKS_MREC_MBMR_0002_R001 : .WABOOKS_MREC_MBMR_0003_R001, body: requestBody, responseType: WABOOKS_MREC_MBMR_0002_R001.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    //Modify OTP Forget ID and Password
    func requestModifyOTP(vcType: VCType, USER_NM: String, CLPH_NO: String, CRTC_NUM: String, completion: @escaping (Swift.Result<WABOOKS_MREC_MBMR_0002_R002.RESPONSE?, NSError>) -> Void) {

        let requestBody = WABOOKS_MREC_MBMR_0002_R002.REQUEST(USER_NM: USER_NM, CLPH_NO: CLPH_NO, CRTC_NUM: CRTC_NUM)

        DataAccess.shared.fetchData(apiKey: vcType == .ForgetID ? .WABOOKS_MREC_MBMR_0002_R002 : .WABOOKS_MREC_MBMR_0003_R002, body: requestBody, responseType: WABOOKS_MREC_MBMR_0002_R002.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
