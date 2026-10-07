//
//  Protocol.swift
//  WeCMS_iOS
//
//  Created by Hai Sombo on 1/20/24.
//

import Foundation

// MARK: - MREC_BLTB_0004_R001_0004_R002_RES
protocol MREC_BLTB_0004_R001_0004_R002_RES  : Decodable, Equatable {
    
    var USER_NM         : String? { get set }
    var USER_ID         : String? { get set }
    var USER_IMG_URL    : String? { get set }
    var USER_IMG        : String? { get set }
}

// MARK: - MREC_BLTB_0002_R001_0002_R004_0002_R005_0002_R004
protocol MREC_BLTB_0002_R001_0002_R004_0002_R005_0002_R004 : Decodable , Equatable  {
    
    var BLTB_CD             : String? { get set }
    var POST_SEQ_NO         : String? { get set }
    var POST_TITLE          : String? { get set }
    var POST_TYPE_CD        : String? { get set }
    var POST_STTS           : String? { get set }
    var POST_APPR_DV        : String? { get set }
    var REG_NM              : String? { get set }
    var REG_ID              : String? { get set }
    var REG_DTM             : String? { get set }
    var REG_IMG_URL         : String? { get set }
    var PIN_POST_TYPE       : String? { get set }
    var PIN_POST_DUE_DT     : String? { get set }
    var POST_CONT           : String? { get set }
    var TOT_CMT             : String? { get set }
    var APPR_SEQ_NO         : String? { get set }
    var PAY_END_YN          : String? { get set }
    var PAY_YN              : String? { get set }
    var READ_YN             : String? { get set }
    var DEL_YN              : String? { get set }
    var APPR_TYPE_CD        : String? { get set }
    var APPRVR_TOT_CNT      : String? { get set }
    var APPRVR_APPR_TOT_CNT : String? { get set }
    var DRAFT_POST_SEQ_NO   : String? { get set }
    
    
}


// MARK: - MREC_BLTB_0004_U001_0004_U002_REQUEST
protocol MREC_BLTB_0004_U001_0004_U002_REQUEST  : Encodable {
    
    var  BLTB_CD        : String? {get set}
    var  POST_SEQ_NO    : String? {get set}
    var  POST_TITLE     : String? {get set}
    var  POST_CONT      : String? {get set}
    
}

// MARK: - MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001
protocol MREC_BLTB_0004_U001_0004_U002_REQUEST_REC2_REC3_0005_U001_0002_C001_0002_U001_REC : Codable , Equatable {
    
    var FILE_NM   : String?     {get set}
    var FILE_DATA : String?     {get set}
    var ORG_FILE_NM : String?    {get set}
    var SAVE_FILE_NM : String?  {get set}
    var FILE_SIZE : String?      {get set}
    var COPY_FILE_YN : String?   {get set}
}

// MARK: - MREC_BLTB_0006_R001_0006_R002_REC
protocol MREC_BLTB_0006_R001_0006_R002_0006_R003_REC : Decodable , Equatable  {
    
    var USER_ID      : String? {get set}
    var USER_NM      : String? {get set}
    var USER_IMG_URL : String? {get set}
    var USER_IMG     : String? {get set}
    var MMB_TYPE     : String? {get set}
    var BLTB_USER_TYPE : String? {get set}
    
}

// MARK: - MREC_BLTB_0006_R001_0006_R002_0002_R002_REQUEST
protocol MREC_BLTB_0006_R001_0006_R002_0002_R002_REQUEST: Encodable   {
    
    var BLTB_CD : String? {get set }
    var SRCH_WD : String? {get set }
    
}
// MARK: - MREC_BLTB_0002_R002_REC
protocol MREC_BLTB_0002_R002_REC : Decodable , Equatable {
    var   BLTB_CD    : String? {get set }
    var   BLTB_NAME  : String? {get set }
}


protocol MREC_BLTB_0004_R002_REQUEST : Encodable {
    var BLTB_CD   : String? {get set }
    var USER_NM   : String? {get set }
}

// MARK: - MREC_BLTB_0006_D001_0006_D002__0006_R003_0006_C001_REQUEST
protocol MREC_BLTB_0006_D001_0006_D002_0006_R003_0006_C001_0006_U001_REQUEST  : Encodable ,Equatable  {
    
    var BLTB_CD : String? {get set }
    var USER_ID : String? {get set }
    
}

// MARK: - MREC_BLTB_0001_R001_REC_REC2
protocol MREC_BLTB_0001_R001_REC_REC2  : Decodable , Equatable {
    
    
    var TOT_CNT_NEW_POST : String? {get set }
    var BLTB_CD          : String? {get set }
    var BLTB_NAME        : String? {get set }
    var CONT             : String? {get set }
    var BLTB_ICON        : String? {get set }
    var BLTB_USER_TYPE   : String? {get set }
    var DEL_YN           : String? {get set }
}

// MARK: - MREC_BLTB_0002_D002_0002_U001_REQUEST
protocol  MREC_BLTB_0002_D002_0002_U001_REQUEST  : Encodable {
    
    var BLTB_CD       : String? {get set }
    var POST_SEQ_NO   : String? {get set }
    var COMNT_SEQ_NO  : String? {get set }
}

// MARK: - MREC_BLTB_0005_R002_0005_R001
protocol MREC_BLTB_0005_R002_0005_R001_0002_R003  : Codable {
    
    var FILE_ID      : String? {get set}
    var ORG_FILE_NM  : String? {get set}
    var SAVE_FILE_NM : String? {get set}
    var FILE_SIZE    : String? {get set}
    var FILE_URL     : String? {get set}
    var FILE_TYPE    : String? {get set}
}

// MARK: - MREC_BLTB_0005_R001_0005_R002_RESPONSE
protocol MREC_BLTB_0005_R001_0005_R002_0003_R001_RESPONSE  : Codable {
    
    
    var DRAFT_POST_SEQ_NO : String? {get set}
    var BLTB_CD         : String? {get set}
    var POST_SEQ_NO     : String? {get set}
    var POST_TITLE      : String? {get set}
    var POST_TYPE_CD    : String? {get set}
    var POST_STTS       : String? {get set}
    var POST_APPR_DV    : String? {get set}
    var REG_NM          : String? {get set}
    var REG_ID          : String? {get set}
    var REG_DTM         : String? {get set}
    var REG_IMG_URL     : String? {get set}
    var PIN_POST_TYPE   : String? {get set}
    var PIN_POST_DUE_DT : String? {get set}
    var POST_CONT       : String? {get set}
    var TOT_CMT         : String? {get set}
    var READ_YN         : String? {get set}
    var DEL_YN          : String? {get set}
    var TOT_PAY_LOC_AMT : String? {get set}
    var TOT_PAY_USD_AMT : String? {get set}
    var APPR_SEQ_NO     : String? {get set}
    var PAY_END_YN      : String? {get set}
    var PAY_YN          : String? {get set}
    var DOC_NO          : String? {get set}
    var APPR_DV         : String? {get set}
    var PAY_REQ_DATE    : String? {get set}
    var PAY_DATE        : String? {get set}
    var APPR_TYPE_CD        : String? {get set}
    var APPRVR_TOT_CNT      : String? {get set}
    var APPRVR_APPR_TOT_CNT : String? {get set}
    var APPR_STTS           : String? {get set}
    var CMTNT_REG_NM    : String? {get set}
    var COMNT_CONT      : String? {get set}
    var COMNT_SEQ_NO    : String? {get set}
    var COMNT_DV_CD     : String? {get set}
    var COMNT_TASK_CD   : String? {get set}
    
}

// MARK: - MREC_BLTB_0005_R001_0005_R002_0002_R003_0002_D001_REQUEST
protocol MREC_BLTB_0005_R001_0005_R002_0002_R003_0002_D001_0005_D001_REQUEST : Codable {
    
    var POST_SEQ_NO : String? {get set }
    var BLTB_CD     : String? {get set }
    
}

// MARK: - MREC_BLTB_0004_U002_REC
protocol MREC_BLTB_0004_U002_REC : Encodable , Equatable {
    
    var FILE_TYPE  : String? {get  set }
    var FILE_ID    : String? {get  set }
}


// MARK: - MREC_BLTB_0006_R003_RESPONSE
protocol MREC_BLTB_0006_R003_0006_R001_0003_R001_RESPONSE : Decodable {
    
    var TOT_CNT           : String? {get set }
    var BLTB_NAME         : String? {get set }
    var CONT              : String? {get set }
    var BLTB_USER_TYPE    : String? {get set }
    
}

// MARK: - MREC_BLTB_0003_U001_REQUEST
protocol  MREC_BLTB_0003_U001_REQUEST : Encodable {
    
    var BLTB_CD   : String? {get set}
    var BLTB_NAME : String? {get set}
    var CONT      : String? {get set}
}


// MARK: - MREC_BLTB_0002_R004
protocol MREC_BLTB_0002_R004_0002_R001_RESPONSE : Decodable  {
    var TOT_CNT        : String? {get set }
    var TOT_CNT_ART    : String? {get set }
    var TOT_CNT_APPR   : String? {get set }
    var TOT_CNT_DRAFT  : String? {get set }
    
    
}

// MARK: - MREC_BLTB_0002_R004
protocol MREC_BLTB_0002_R004_0002_R001_0002_R005_0003_R001_REQUEST: Encodable  {
    
    var POST_TYPE_CD   : String? {get set }
    var SRCH_WD        : String? {get set }
    var PAGE_NO        : String? {get set }
    var PAGE_PER_CNT   : String? {get set }
}

// MARK: - MREC_BLTB_0001_C001
protocol MREC_BLTB_0001_C001_REQUEST : Encodable {
    
    var BLTB_NAME  : String? {get set }
    var CONT       : String? {get set }
}


// MARK: - MREC_BLTB_0002_R003_REC
protocol MREC_BLTB_0002_R003_REC : Decodable {
    
    var REG_NM         : String? {get set }
    var REG_DTM        : String? {get set }
    var REG_ID         : String? {get set }
    var REG_IMG_URL    : String? {get set }
    var COMNT_CONT     : String? {get set }
    var BLTB_CD        : String? {get set }
    var POST_SEQ_NO    : String? {get set }
    var COMNT_SEQ_NO   : String? {get set }
    var COMNT_DV_CD    : String? {get set }
    var COMNT_TASK_CD  : String? {get set }
    
}

// MARK: - MREC_BLTB_0002_C001_REQUEST
protocol MREC_BLTB_0002_C001_REQUEST : Encodable{
    
    var BLTB_CD       : String? {get set }
    var POST_SEQ_NO   : String? {get set }
    var COMNT_DV_CD   : String? {get set }
    var COMNT_TASK_CD : String? {get set }
    var COMNT_CONT    : String? {get set }
}

// MARK: - MREC_BLTB_0004_U002_REC
protocol MREC_BLTB_0004_U002_REC1 : Encodable , Equatable, Hashable {
    
    var APPRVR_ID : String? {get set}
    var APPRVR_NM : String? {get set}
}

// MARK: - MREC_BLTB_0001_U001_REQUEST
protocol MREC_BLTB_0001_U001_0003_D001_REQUEST  : Encodable {
    
    var  BLTB_CD : String? {get set }
    
}

// MARK: - MREC_BLTB_0002_U001_REC
protocol MREC_BLTB_0002_U001_0004_C001_REC : Encodable , Equatable  {
    
    var FILE_ID  : String? {get set }
}


// MARK: - MREC_BLTB_0005_U001_REQUEST
protocol MREC_BLTB_0005_U001_REQUEST: Codable {
    
    var  APPR_SEQ_NO : String? {get set }
    var  APPRVR_STTS : String? {get set }
    var  BLTB_CD     : String? {get set }
    var  COMNT_CONT  : String? {get set }
    
}

// MARK: - MREC_BLTB_0005_R002_REC
protocol MREC_BLTB_0005_R002_0004_R003_REC : Codable, Equatable {
    
    var DOC_ID       : String? {get set }
    var ISSU_DT      : String? {get set }
    var DOC_TYPE     : String? {get set }
    var TRCO_KEY     : String? {get set }
    var TRCO_CMNM    : String? {get set }
    var TRCO_CMENM   : String? {get set }
    var CCY_CD       : String? {get set }
    var AMT          : String? {get set }
    var MEMO         : String? {get set }
    var BUSA_USAG_CD : String? {get set }
    var USAG_NM      : String? {get set }
    var DISP_DOC_ID  : String? {get set }
    var TRCO_TRSC_CCY_CD    : String? {get set } // Customer transaction currency code
    var TOTL_AMT            : String? {get set } // Total Amount
    var COLOR               : String? {get set }
    var TRCO_TAX_ID         : String? {get set } // Contacts Tax ID
    var APPR_DV             : String? {get set }
    
}


// MARK: - MREC_BLTB_0005_R002_REC
protocol MREC_BLTB_0005_R002_REC : Codable {
    
    var APPRVR_ID           : String? { get set }
    var APPRVR_IMG_URL      : String? { get set }
    var APPR_DTM            : String? { get set }
    var CCY_CD              : String? { get set }
    var APPRVR_STTS         : String? { get set }
    var APPRVR_LINE_NO      : String? { get set }
    var APPRVR_NM           : String? { get set }
//    var APPR_TYPE_CD        : String? { get set }
//    var APPRVR_TOT_CNT      : String? { get set }
//    var APPRVR_APPR_TOT_CNT : String? { get set }
    
}


// MARK: - MREC_BLTB_0004_R003_REQUEST
protocol MREC_BLTB_0004_R003_REQUEST : Encodable {
    
    var SRCH_WD      : String? {get set }
    var EXPT_TYPE    : String? {get set }
    var FROM_DT      : String? {get set }
    var TO_DT        : String? {get set }
    var PAGE_NO      : Int? {get set }
    var PAGE_PER_CNT : Int? {get set }
    
}

// MARK: - MREC_R009
protocol MREC_R009_REC : Decodable, Equatable {
    
    var REG_DT        : String? {get set}
    var SEQ_NO        : String? {get set}
    var FILE_ID       : String? {get set}
    var SAVE_FILE_NM  : String? {get set}
    var FILE_URL      : String? {get set}
    var ORG_FILE_NM   : String? {get set}
    var FILE_SIZE     : String? {get set}
    
}


protocol MREC_BLTB_0002_D003_REQUEST : Encodable {
    var BLTB_CD           : String? {get set}
    var DRAFT_POST_SEQ_NO : String? {get set}
}
