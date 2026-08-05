//
//  CountryDataVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Ly Manny on 12/8/22.
//

import Foundation

class CountryDataVM {
    
    func getCountryData() {
        let url     = URL(string: Shared.New_MG?.country_dial_codes_url ?? "")
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        session.dataTask(with: request) { (data, response, error) in
            guard let responseHttp = response as? HTTPURLResponse, responseHttp.statusCode == 200 else{
                return
            }
            guard let data = data else {
                return
            }
            print("===>data", data)
            do {
                let result = try JSONDecoder().decode([CountryData].self, from: data)
                Shared.countryData = result
                self.removeCountryDialCodesFristOrder()
                self.addCountryDialCodesFristOrder()
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
//    func sortDataCountry() {
//        print("===>countryData", Shared.countryData)
//
//        for (index, value) in Shared.countryData.enumerated() {
//            if value.dial_code == "+855" {
//                Shared.countryData.remove(at: index)
//                Shared.countryData.insert(value, at: 0)
//            } else if value.dial_code == "+84" {
//                Shared.countryData.remove(at: index)
//                Shared.countryData.insert(value, at: 1)
//            } else if value.dial_code == "+82" {
//                Shared.countryData.remove(at: index)
//                Shared.countryData.insert(value, at: 1)
//            } else {
//
//            }
//        }
//
//        print("===>countryData", Shared.countryData)
//    }
    
    func removeCountryDialCodesFristOrder() {

        for (index, value) in Shared.countryData.enumerated() {
            if value.dial_code == "+855" {
                Shared.countryData.remove(at: index)
            } else if value.dial_code == "+84" {
                Shared.countryData.remove(at: index - 2)
            } else if value.dial_code == "+82" {
                Shared.countryData.remove(at: index - 1)
            }
        }
        
    }
    
    func addCountryDialCodesFristOrder() {
        
        let obj1 = CountryData(name: Shared.New_MG?.country_dial_codes_as_frist_order[0].name ?? "", dial_code: Shared.New_MG?.country_dial_codes_as_frist_order[0].dial_code ?? "", code: Shared.New_MG?.country_dial_codes_as_frist_order[0].code ?? "")
        let obj2 = CountryData(name: Shared.New_MG?.country_dial_codes_as_frist_order[1].name ?? "", dial_code: Shared.New_MG?.country_dial_codes_as_frist_order[1].dial_code ?? "", code: Shared.New_MG?.country_dial_codes_as_frist_order[1].code ?? "")
        let obj3 = CountryData(name: Shared.New_MG?.country_dial_codes_as_frist_order[2].name ?? "", dial_code: Shared.New_MG?.country_dial_codes_as_frist_order[2].dial_code ?? "", code: Shared.New_MG?.country_dial_codes_as_frist_order[2].code ?? "")

        Shared.countryData.insert(obj1, at: 0)
        Shared.countryData.insert(obj2, at: 1)
        Shared.countryData.insert(obj3, at: 2)
    }
    
}
