//
//  CompanyModel.swift
//  PopUpScreen
//
//  Created by Tang Mouycheng on 27/3/23.
//

import Foundation

enum CompanyRowType : String, CaseIterable{
    case title 
    case company
}

struct CompanyNewData <T> {
    var rowType     : CompanyRowType?
    var value       : T?
}

struct CompanyInfo {
    var images      : String?
    var compName    : String?
    var rowType     : CompanyRowType?
    
}
   
   


