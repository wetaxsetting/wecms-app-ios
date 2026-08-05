//
//  MentionMemberVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Navy on 22/1/24.
//

import Foundation

class MentionMemberVM {
    
    var cells        : [MentionMemberUIModel] = []
    var filteredList : [MentionMemberUIModel] = []

    
    func filterMember(searchText: String) {
        filteredList =  self.cells.filter({($0.name.localizedCaseInsensitiveContains(searchText))})
    }
    
    func initCellData(data: [WABOOKS_MREC_BLTB_0004_R001.RESPONSE.REC]) {
        
        cells = []
        filteredList = []
        for obj in data {
            filteredList.append(MentionMemberUIModel(name: obj.USER_NM ?? "", email: obj.USER_ID ?? "", photo: obj.USER_IMG_URL ?? "", USER_IMG: obj.USER_IMG ?? ""))
        }
        
    }
    

    func requestMentionMembers(body: WABOOKS_MREC_BLTB_0004_R001.REQUEST, completion: @escaping (Swift.Result<WABOOKS_MREC_BLTB_0004_R001.RESPONSE?, NSError>) -> Void) {
        DataAccess.shared.fetchData(shouldShowLoading: true, apiKey: .WABOOKS_MREC_BLTB_0004_R001,httpMethod: .POST, body: body, responseType: WABOOKS_MREC_BLTB_0004_R001.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.initCellData(data: data.REC ?? [])
                completion(.success(nil))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}
