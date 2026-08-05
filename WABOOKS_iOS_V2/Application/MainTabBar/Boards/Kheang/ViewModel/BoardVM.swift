//
//  ViewModel.swift
//  WABOOKS_iOS_V2
//
//  Created by Bong Kokkheang on 15/1/24.
//

import Foundation

class BoardsVM {
    
    var content         : [Boards]          = []
    var sectionData     : [Boards.Section]  = []
    var pinData         : [Boards]          = []
    var normalData      : [Boards]          = []
    var boardType       : Boards.BoardType  = .Approval
    var selectedData    : Boards.Section!
    var response        : WABOOKS_MREC_BLTB_0002_R001.RESPONSE?
    var isShowLoading   : Bool              = true
    var PAGE_NO                             = 1
    var LAST_PAGE_NO                        = 1
    var isFetching                          = false
    var showMore                            = false
    
    func initDataWeCMSApproval(location: Int) {
        content = []
        pinData = []
        normalData = []
        
        if let REC2 = response!.REC2 {
            for (_, c) in REC2.enumerated() {
                let temp = [
                    Boards.Content(REC: c, rowType: .STATUS),
                    Boards.Content(REC: c, rowType: .DESCRIPTION),
                    Boards.Content(REC: c, rowType: .COMMENT),
                    Boards.Content(REC: c, rowType: .LINEFOOTER),
                ]
                pinData.append(Boards(sectionType: .CONTENT, content: temp))
            }
        }

        if pinData.count > 0 {
            //            content = []
            // insert board pinned title section
            //            content.insert(Boards(sectionType: .TITLE, isPin: true, title: "pinned".localized), at: 0)
            content.append(Boards(sectionType: .TITLE, isPin: true, title: "pinned".localized))
            var singlePinData = pinData.first!
            
            // remove footerUnderLine cell in content in last item
            singlePinData.content.removeLast()
            
            // insert section data to content
            content.append(singlePinData)
            if pinData.count > 1 {
                // check if pin data has more than 1 show Show more section cell
                content.append(Boards(sectionType: .SHOWMORE))
                // insert All Posts title section cell in item index 3
                content.append(Boards(sectionType: .TITLE, title: sectionData[location].title))
                //                content.insert(Boards(sectionType: .TITLE, title: sectionData[get_location().row].title), at: 3)
            } else {
                content.append(Boards(sectionType: .PINLINE))
                // insert All Posts title section cell in item index 2
                content.append(Boards(sectionType: .TITLE, title: sectionData[location].title))
                //                content.insert(Boards(sectionType: .TITLE, title: sectionData[get_location().row].title), at: 3)
            }
            
        }
        
        for (_, c) in response!.REC!.enumerated() {
            
            var temp : [Boards.Content] = []
            
            temp.append(Boards.Content(REC: c, rowType: .STATUS))
            temp.append(Boards.Content(REC: c, rowType: .DESCRIPTION))
//            if c.POST_SEQ_NO != nil {
//                temp.append(Boards.Content(REC: c, rowType: .COMMENT))
//            }
            temp.append(Boards.Content(REC: c, rowType: .LINEFOOTER))
            content.append(Boards(sectionType: .CONTENT, content: temp))
            normalData.append(Boards(sectionType: .CONTENT, content: temp))
        }
        
        //we need to init section data again cuz section count data need up to date from requesting from api.
        initWeCMSApproval()
        sectionData[location].isSelected = true
    }
    
    func appendData(data: WABOOKS_MREC_BLTB_0002_R001.RESPONSE?) {
        for (_, c) in data!.REC!.enumerated() {
            var temp : [Boards.Content] = []
            
            temp.append(Boards.Content(REC: c, rowType: .STATUS))
            temp.append(Boards.Content(REC: c, rowType: .DESCRIPTION))
            if c.POST_SEQ_NO != nil {
                temp.append(Boards.Content(REC: c,  rowType: .COMMENT))
            }
            temp.append(Boards.Content(REC: c, rowType: .LINEFOOTER))
            content.append(Boards(sectionType: .CONTENT, page: PAGE_NO, content: temp))
            normalData.append(Boards(sectionType: .CONTENT, content: temp))
        }
    }
    
    func replaceData(data: WABOOKS_MREC_BLTB_0002_R001.RESPONSE?) {
        
        var tmp : [WABOOKSStruct.BoardDetail_Protocol] = []
        var tempPinData : [Boards] = []
    
        if let REC2 = response!.REC2 {
            if REC2.count > 0 {
                tmp = REC2
//                pinData = []
            }
            for (_, c) in REC2.enumerated() {
                let temp = [
                    Boards.Content(REC: c, rowType: .STATUS),
                    Boards.Content(REC: c, rowType: .DESCRIPTION),
                    Boards.Content(REC: c, rowType: .COMMENT),
                    Boards.Content(REC: c, rowType: .LINEFOOTER),
                ]
                tempPinData.append(Boards(sectionType: .CONTENT, content: temp))
            }
        }
        
        var tempData : [Boards] = []
        for (_, c) in data!.REC!.enumerated() {
            var temp : [Boards.Content] = []
            
            temp.append(Boards.Content(REC: c, rowType: .STATUS))
            temp.append(Boards.Content(REC: c, rowType: .DESCRIPTION))
            if c.POST_SEQ_NO != nil {
                temp.append(Boards.Content(REC: c,  rowType: .COMMENT))
            }
            temp.append(Boards.Content(REC: c, rowType: .LINEFOOTER))
            tempData.append(Boards(sectionType: .CONTENT, page: PAGE_NO, content: temp))
        }
        
        let range = ( PAGE_NO - 1 ) * 10 + getPinDataCount()
        let rangeNormalData = ( PAGE_NO - 1 ) * 10
        
        let endIndex = range + tempData.count - 1
        let startIndex = range
        
        if PAGE_NO == LAST_PAGE_NO {
            if startIndex >= 0 && endIndex < content.count && startIndex <= endIndex {
                content.removeSubrange(startIndex...endIndex)
            } else {
                #warning("Range is out of bound")
                return
            }
            content.append(contentsOf: tempData)
            normalData.removeSubrange((rangeNormalData)...(rangeNormalData + tempData.count - 1))
            normalData.append(contentsOf: tempData)
        } else {
            content.replaceSubrange((range)...(range + tempData.count - 1), with: tempData)
            normalData.replaceSubrange((rangeNormalData)...(rangeNormalData + tempData.count - 1), with: tempData)
        }
        
        /// this block is execute only when the repsonse REC2 ~ (pin data) has data.
        if tmp.count > 0 {
            
            if showMore {
                
                var temp = tempPinData
                
                /// range pin data section
                let range = 0...(2 + pinData.count - 1)
                content.removeSubrange(range)
                
                pinData = tempPinData
                
                /// remove LINEFOOTER at last item of pin data
                temp[temp.count - 1].content.removeLast()
                
                /// add SHOWLESS row to pin data
                temp.append(Boards(sectionType: .SHOWLESS))
                
                /// we need pin data to sum with content cell
                content = temp + content
                
                /// insert Pin title cell to content cell
                content.insert(Boards(sectionType: .TITLE, isPin: true, title: "pinned".localized), at: 0)
                
            } else {
                
                content.removeSubrange(0...3)
                // insert board pinned title section
                content.insert(Boards(sectionType: .TITLE, isPin: true, title: "pinned".localized), at: 0)
                
                var singlePinData = tempPinData.first!
                singlePinData.content.removeLast() // remove footerUnderLine cell in content in last item
                // insert section data to content
                content.insert(singlePinData, at: 1)
                
                if pinData.count > 1 {
                    // check if pin data has more than 1 show Show more section cell
                    content.insert(Boards(sectionType: .SHOWMORE), at: 2)
                    // insert All Posts title section cell in item index 3
    //                content.append(Boards(sectionType: .TITLE, title: sectionData[get_location().row].title))
                    content.insert(Boards(sectionType: .TITLE, title: sectionData[get_location()].title), at: 3)
                } else {
                    content.insert(Boards(sectionType: .PINLINE), at: 2)
                    // insert All Posts title section cell in item index 2
                    content.insert(Boards(sectionType: .TITLE, title: sectionData[get_location()].title), at: 3)
                }
            }
        }
    }
    
    func getPinDataCount() -> Int {
        if pinData.count > 0 {
            if showMore {
                return pinData.count + 3
            } else {
                return 1 + 3
            }
        } else {
            return 0
        }
    }
    
    func initShowMoreData() {
        
        showMore = true
        var temp = pinData
        
        /// range pin data section
        let range = 0...2
        content.removeSubrange(range)
        
        /// remove LINEFOOTER at last item of pin data
        temp[temp.count - 1].content.removeLast()
        
        /// add SHOWLESS row to pin data
        temp.append(Boards(sectionType: .SHOWLESS))
        
        /// we need pin data to sum with content cell
        content = temp + content
        
        /// insert Pin title cell to content cell
        content.insert(Boards(sectionType: .TITLE, isPin: true, title: "pinned".localized), at: 0)
    }
    
    func initShowLessData() {
        showMore = false
        
        /// range pin data section
        let range = 0...(2 + pinData.count - 1)
        content.removeSubrange(range)
        
        var singlePinData = pinData.first!
        singlePinData.content.removeLast() // remove footerUnderLine cell in content in last item
        
        // insert board pinned title section
        content.insert(Boards(sectionType: .TITLE, isPin: true, title: "pinned".localized), at: 0)
        
        // insert section data to content
        content.insert(singlePinData, at: 1)
        
        if pinData.count > 1 {
            // check if pin data has more than 1 show Show more section cell
            content.insert(Boards(sectionType: .SHOWMORE), at: 2)
            // insert All Posts title section cell in item index 3
//            content.insert(Boards(sectionType: .TITLE, title: sectionData[get_location().row].title), at: 3)
        } else {
            // insert All Posts title section cell in item index 2
//            content.insert(Boards(sectionType: .TITLE, title: sectionData[get_location().row].title), at: 2)
        }
        
//        normalData = content
    }
    
    func initSectionData() {
        sectionData = [
            Boards.Section(name: "All",         title: "all_posts".localized, count: response?.TOT_CNT, isSelected: true, sectionType: .ALL),
            Boards.Section(name: "Draft",       title: "draft".localized, image: "ico_draft", count: response?.TOT_CNT_DRAFT, sectionType: .DRAFT),
            Boards.Section(name: "Article",     title: "article".localized, image: "ico_document", count: response?.TOT_CNT_APPR, sectionType: .DOCUMENT),
            Boards.Section(name: "Approval",    title: "approval".localized, image: "ico_check", count: response?.TOT_CNT_ART, sectionType: .CHECK)
        ]
//        selectedData = sectionData.first
    }
    
    func initWeCMSApproval() {
        sectionData = [
            Boards.Section(name: "all".localized, title: "all_posts".localized, count: response?.TOT_CNT, sectionType: .ALL),
            Boards.Section(name: "draft".localized, title: "draft".localized, image: "ico_draft", count: response?.TOT_CNT_DRAFT, sectionType: .DRAFT),
            Boards.Section(name: "pending".localized, title: "pending".localized, image: "ico_waiting", count: response?.TOT_CNT_APPR_PD, sectionType: .Pending),
            Boards.Section(name: "progress".localized, title: "progress".localized, image: "ico_clock", count: response?.TOT_CNT_APPR_PP, sectionType: .Progress),
            Boards.Section(name: "rejected".localized, title: "rejected".localized, image: "ico_nosign", count: response?.TOT_CNT_APPR_RJ, sectionType: .Reject),
            Boards.Section(name: "approved".localized, title: "approved".localized, image: "ico_check", count: response?.TOT_CNT_APPR_AP, sectionType: .Approved),
        ]
    }
    
    private func get_POST_APPR_TYPE_CD() -> String {
        return selectedData?.sectionType.rawValue ?? ""
    }
    
    func get_location() -> Int {
        guard let index = sectionData.firstIndex(where: {$0.isSelected}) else {
            return 0
        }
        return index
    }
    
    func fetchBoardWeCMS(FROM_DT: String = "", TO_DT: String = "", completion  : @escaping (Swift.Result<WABOOKS_MREC_BLTB_0002_R001.RESPONSE, NSError>) -> Void) {
        isFetching = true
        fetchApproval(FROM_DT: FROM_DT, TO_DT: TO_DT) { result in
            completion(result)
        }
    }
    
    func fetchApproval(FROM_DT: String = "", TO_DT: String = "", completion  : @escaping (Swift.Result<WABOOKS_MREC_BLTB_0002_R001.RESPONSE, NSError>) -> Void) {
        let body = WABOOKS_MREC_BLTB_0002_R005.REQUEST(POST_APPR_TYPE_CD: get_POST_APPR_TYPE_CD(), PAGE_NO: String(PAGE_NO), PAGE_PER_CNT: "10", FROM_DT: FROM_DT, TO_DT: TO_DT)
        DataAccess.shared.fetchData(shouldShowLoading   : true,
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
    
    //Delete Post
    func requestDeletePost(body: WABOOKS_MREC_BLTB_0002_D001.REQUEST, completion: @escaping (NSError?) -> ()) {
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
    
    //Delete Draft Post
    func requestDeleteDraftPost(body: WABOOKS_MREC_BLTB_0002_D003.REQUEST,completion: @escaping (NSError?) -> ())  {
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
    
}
