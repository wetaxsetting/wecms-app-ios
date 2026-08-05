//
//  WABOOKS_MREC_C002.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 15/1/21.
//

import Foundation

/**
 API: WABOOKS_MREC_C002 - 사진업로드하기
 **/

struct WABOOKS_MREC_C002 {
    
    struct REQUEST: Encodable {
        
//        let FILE_NM         : String    // 파일명
//        let FILE_DATA       : String
        let REC_IN          : [REC]
        
        struct REC: Encodable {
            let FILE_NM         : String    // 파일명
            let FILE_DATA       : String    // 파일데이터
            
            // ※ 모바일 팀에서 올리는 파일 Binary 데이터를
            //
            // /WAS_DATA/webRoot/wabooks/file/{biz_key}/WABOOKS_MREC_C002
            //
            // 디렉토리에 업로드 후(파일명은 FILE_NM Input 값 대로) URL 정보를 Return.
            //
            // (※ 이 때 FILE_NM이 중복될 경우 파일명 뒤에 Sequence 붙여서 저장)
        }
       
    }
    
    
    struct RESPONSE: Decodable {
        let REG_DT          : String?    //테이블에 Insert한 REG_DT 컬럼값.
        let SEQ_NO          : Int?    //테이블에 Insert한 SEQ_NO 컬럼값.
        let FILE_URL        : String?
        let REC_OUT         : [REC_OUT]?

        struct REC_OUT : Decodable {
            let FILE_URL        : String    // 파일URL    | {와북URL}/file/{biz_key}/WABOOKS_MREC_C002/{FILE_NM} 형태로 Return.
        }
    }
}

struct FileModel {
    let fileName : String
    let filePath : String
    let fileData : Data
    let fileSize : String
    let fileURL  : String?
    var isFromLocal: Bool = true
    
    init(fileName: String, filePath: String, fileData: Data, fileSize: String, fileURL: String?, isFromLocal: Bool) {
        self.fileName = fileName
        self.filePath = filePath
        self.fileData = fileData
        self.fileSize = fileSize
        self.fileURL = fileURL
        self.isFromLocal = isFromLocal
    }
}
