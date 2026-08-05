//
//  SearchVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 2/2/24.
//

import Foundation

class SearchVM {
    
    var content: [Boards] = []
    var response : WABOOKS_MREC_BLTB_0002_R001.RESPONSE?
    var isShowLoading : Bool = true
    var PAGE_NO = 1
    var BLTB_CD = ""
    var isSearch = true


    func fetchApprovalSearch(SRCH_WD: String = "", FROM_DT: String = "", TO_DT: String = "", completion: @escaping (Swift.Result<WABOOKS_MREC_BLTB_0002_R001.RESPONSE, NSError>) -> Void) {
        let body = WABOOKS_MREC_BLTB_0002_R001.REQUEST(POST_APPR_TYPE_CD: "", POST_TYPE_CD: "", SRCH_WD: SRCH_WD, PAGE_NO: String(PAGE_NO), PAGE_PER_CNT: "10", FROM_DT: "", TO_DT: "")
        DataAccess.shared.fetchData(shouldShowLoading   : false,
                                    apiKey              : APIKey.WABOOKS_MREC_BLTB_0002_R005,
                                    body                : body,
                                    responseType        : WABOOKS_MREC_BLTB_0002_R001.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.response = data
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSearch(SRCH_WD: String = "", FROM_DT: String = "", TO_DT: String = "", completion  : @escaping (Swift.Result<WABOOKS_MREC_BLTB_0002_R001.RESPONSE, NSError>) -> Void) {
        isShowLoading = true
        fetchApprovalSearch(SRCH_WD: SRCH_WD, FROM_DT: FROM_DT, TO_DT: TO_DT) { result in
            completion(result)
        }
    }

    func deletePost(body: WABOOKS_MREC_BLTB_0002_D001.REQUEST, completion: @escaping (NSError?) -> ()) {
        DataAccess.shared.fetchData(apiKey: .WABOOKS_MREC_BLTB_0002_D001,
                                    body: body,
                                    responseType: WABOOKS_MREC_BLTB_0002_D001.RESPONSE.self) { result in
            switch result {
            case .success(_) :
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func deleteDraftPost(body: WABOOKS_MREC_BLTB_0002_D003.REQUEST,completion: @escaping (NSError?) -> ())  {
        DataAccess.shared.fetchData(apiKey: .WABOOKS_MREC_BLTB_0002_D003,
                                    body: body,
                                    responseType: WABOOKS_MREC_BLTB_0002_D003.RESPONSE.self) { result in
            switch result {
            case .success(_) :
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func initData(isPagination: Bool = false) {
        if !isPagination {
            content = []
        }
        for (_, c) in response!.REC!.enumerated() {
            let temp = [
                Boards.Content(REC: c, rowType: .STATUS),
                Boards.Content(REC: c, rowType: .LINEFOOTER),
            ]
            content.append(Boards(sectionType: .CONTENT, content: temp))
        }
    }
    
}
