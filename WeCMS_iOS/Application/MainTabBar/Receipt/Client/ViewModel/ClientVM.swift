//
//  ClientVM.swift
//  RecipetDetail
//
//  Created by Bong Kokkheang on 28/3/23.
//

import Foundation

class ClientVM {
    var receiptList     : MREC_R006.RESPONSE.REC?
    var contentData     : [Client.ContentBody]   = []
    var tempContentData : [Client.ContentBody]   = []
    var recentlyData    : [Client.InfoData<Any>] = []
    var favouriteData   : [Client.InfoData<Any>] = []
    var entireData      : [Client.InfoData<Any>] = []
    lazy var selectedData: Client.InfoData<Any>? = {
        return contentData.flatMap({$0.item.filter({$0.rowType == .Item && (($0.value as! Client.ContentBody.Item).isSelected ?? false)})}).first
    }()
    
    func fetchContactList(TRCO_CMNM: String, TRSC_CCY_CD: String, receiptList: MREC_R006.RESPONSE.REC?, completion: @escaping (Swift.Result<MREC_R030.Respone?, NSError>) -> Void) {
        self.receiptList    = receiptList
        let body            = MREC_R030.Request(TRCO_CMNM: TRCO_CMNM, TRSC_CCY_CD: TRSC_CCY_CD)
        
        DataAccess.shared.fetchData(apiKey: APIKey.MREC_R030, body: body, responseType: MREC_R030.Respone.self){ (result) in
            switch result {
            case .success (let data) :
                
                self.contentData.removeAll()
                self.favouriteData.removeAll()
                self.entireData.removeAll()
                self.recentlyData.removeAll()
                
                if data.REC1.count > 0 {
                    self.recentlyData    = [Client.InfoData(rowType: .Title)]
                    var tempRecentlyData : [Client.InfoData<Any>] = []
                    data.REC1.forEach { e in
                        // Condition for set selected E-Invoice
                        let isSelected = e.TRCO_KEY == self.receiptList?.TRCO_KEY ? true : false
                        tempRecentlyData.append(Client.InfoData(rowType: .Item, value:  Client.ContentBody.Item(isSelected: isSelected, l_text: e.TRCO_NICK_NM ?? "", r_text: e.TRCO_TAX_ID, isFavourite: false, TRCO_CMNM: e.TRCO_CMNM, TRCO_CMENM: e.TRCO_CMENM, TRCO_KEY: e.TRCO_KEY ?? "", TRSC_CCY_CD: e.TRSC_CCY_CD ?? "", TRCO_RPRS_TLPH: e.TRCO_RPRS_TLPH ?? "", TRCO_TYPE: e.TRCO_TYPE, EML: e.EML, TRCO_BSUN_POST_ADRS: e.TRCO_BSUN_POST_ADRS, TRCO_BSUN_DTL_ADRS: e.TRCO_BSUN_DTL_ADRS, TRCO_BSUN_CITY: e.TRCO_BSUN_CITY, TRCO_BSUN_ST: e.TRCO_BSUN_ST)))
                    }
                    self.recentlyData.append(contentsOf: tempRecentlyData)
                    self.contentData.append(Client.ContentBody(title: Client.SectionType.Recently.rawValue, item: self.recentlyData, sectionType: .Recently))
                }
                
                if data.REC3.count > 0 {
                    self.favouriteData    = [Client.InfoData(rowType: .Title)]
                    var tempFavouriteData : [Client.InfoData<Any>] = []
                    data.REC3.forEach { e in
                        // Condition for set selected E-Invoice
                        let isSelected = e.TRCO_KEY == self.receiptList?.TRCO_KEY ? true : false
                        tempFavouriteData.append(Client.InfoData(rowType: .Item, value:  Client.ContentBody.Item(isSelected: isSelected, l_text: e.TRCO_NICK_NM ?? "", r_text: e.TRCO_TAX_ID, isFavourite: true, TRCO_CMNM: e.TRCO_CMNM, TRCO_CMENM: e.TRCO_CMENM, TRCO_KEY: e.TRCO_KEY ?? "", TRSC_CCY_CD: e.TRSC_CCY_CD ?? "" ,TRCO_RPRS_TLPH: e.TRCO_RPRS_TLPH ?? "", TRCO_TYPE: e.TRCO_TYPE, EML: e.EML, TRCO_BSUN_POST_ADRS: e.TRCO_BSUN_POST_ADRS, TRCO_BSUN_DTL_ADRS: e.TRCO_BSUN_DTL_ADRS, TRCO_BSUN_CITY: e.TRCO_BSUN_CITY, TRCO_BSUN_ST: e.TRCO_BSUN_ST)))
                    }
                    self.favouriteData.append(contentsOf: tempFavouriteData)
                    self.contentData.append(Client.ContentBody(title: Client.SectionType.Favorite.rawValue, item: self.favouriteData, sectionType: .Favorite))
                }
                
                if data.REC2.count > 0 {
                    self.entireData    = [Client.InfoData(rowType: .Title)]
                    var tempEntireData : [Client.InfoData<Any>] = []
                    
                    for (_, e) in data.REC2.enumerated() {
                        // Condition for set selected E-Invoice
                        
                        var isFavourite = false
                        
                        for (_, obj2) in data.REC3.enumerated() {
                            
                            if e.TRCO_KEY == obj2.TRCO_KEY {
                                
                                // Get full data from R003
                                isFavourite = e.TRCO_KEY == obj2.TRCO_KEY
                                break
                            }
                        }
                        
                        let isSelected = e.TRCO_KEY == self.receiptList?.TRCO_KEY ? true : false
                        tempEntireData.append(Client.InfoData(rowType: .Item, value:  Client.ContentBody.Item(isSelected: isSelected, l_text: e.TRCO_NICK_NM ?? "", r_text: e.TRCO_TAX_ID, isFavourite: isFavourite,  TRCO_CMNM: e.TRCO_CMNM, TRCO_CMENM: e.TRCO_CMENM, TRCO_KEY: e.TRCO_KEY ?? "", TRSC_CCY_CD: e.TRSC_CCY_CD ?? "" ,TRCO_RPRS_TLPH: e.TRCO_RPRS_TLPH ?? "", TRCO_TYPE: e.TRCO_TYPE, EML: e.EML, TRCO_BSUN_POST_ADRS: e.TRCO_BSUN_POST_ADRS, TRCO_BSUN_DTL_ADRS: e.TRCO_BSUN_DTL_ADRS, TRCO_BSUN_CITY: e.TRCO_BSUN_CITY, TRCO_BSUN_ST: e.TRCO_BSUN_ST)))
                    }
                    
                    self.entireData.append(contentsOf: tempEntireData)
                    self.contentData.append(Client.ContentBody(title: Client.SectionType.All.rawValue, item: self.entireData, sectionType: .All))
                }
                
                self.tempContentData = self.contentData
                
                completion(.success(data))
            case.failure(let error) :
                completion(.failure(error))
            }
        }
    }
    
    //NOTE:  text.folding(options: .diacriticInsensitive, locale: .current
    func search(clientData: [Client.ContentBody], text: String, completion: ([Client.ContentBody]) -> ()) {
        var entireData : [Client.InfoData<Any>] = [Client.InfoData(rowType: .Title),
                                                   Client.InfoData(rowType: .Search, value: Client.ContentBody.Item(l_text: text.folding(options: .diacriticInsensitive, locale: .current), r_text: " Manual Input ",  TRCO_CMNM: "", TRCO_CMENM: "", TRCO_KEY: "", TRSC_CCY_CD: "", TRCO_RPRS_TLPH: ""))]
        var temp = [Client.ContentBody(title: Client.SectionType.All.rawValue, item: entireData, sectionType: .All)]
        
        // Filter contact name
        var data : [Client.InfoData<Any>] = []
        let dataTemp = clientData.first(where: {$0.sectionType == .All})?.item.filter({$0.rowType == .Item && ($0.value as! Client.ContentBody.Item).l_text.folding(options: .diacriticInsensitive, locale: .current).lowercased().contains(text.lowercased())})
        if let temp = dataTemp {
            data = temp
        }
        
        // Filter contact ID
        var dataID: [Client.InfoData<Any>] = []
        let dataIDTemp = clientData.first(where: {$0.sectionType == .All})?.item.filter({$0.rowType == .Item && (($0.value as! Client.ContentBody.Item).r_text?.folding(options: .diacriticInsensitive, locale: .current) ?? "").lowercased().contains(text.lowercased())})
        if let tempData = dataIDTemp {
            dataID = tempData
        }
        
        data.append(contentsOf: dataID)
        if data.isEmpty {
            contentData = temp
        } else {
            entireData.insert(contentsOf: data, at: 1)
            temp[0].item = entireData
            contentData = temp
        }
        completion(self.contentData)
    }
    
    func createBookMark(TRCO_KEY: String, completion: @escaping (Swift.Result<MREC_C080.Response, NSError>) -> Void) {
        
        let body = MREC_C080.Request(TRCO_KEY: TRCO_KEY)
        
        DataAccess.shared.fetchData(apiKey: APIKey.MREC_C080, body: body, responseType: MREC_C080.Response.self) { (result) in
            switch result {
            case .success(let success):
                completion(.success(success))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    func deleteBookMark(TRCO_KEY: String, completion: @escaping (Swift.Result<MREC_D080.Response, NSError>) -> Void) {
        
        let body = MREC_D080.Request(TRCO_KEY: TRCO_KEY)
        
        DataAccess.shared.fetchData(apiKey: APIKey.MREC_D080, body: body, responseType: MREC_D080.Response.self) { (result) in
            switch result {
            case .success(let success):
                completion(.success(success))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
}

