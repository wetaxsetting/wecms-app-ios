//
//  DataAccess.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 5/1/21.
//

import Foundation
import UIKit
import FirebaseCrashlytics


class DataAccess {
    
    // MARK: - Singleton
    public static var sharedInstance    = DataAccess()
    
    private static var sessionConfig    : URLSessionConfiguration!
    private static var session          : URLSession!
    
    /** Store downloaded data */
    private var activeDownloads: [URL: Download] = [:]
    
    //Request Timer
    private static var timer            : Timer?
    let timeOutDuration                 : TimeInterval =  6000
    
    static var shared: DataAccess = {
        // Timeout Configuration
        sessionConfig                               = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest     = 60
//        sessionConfig.timeoutIntervalForResource    = 60
        sessionConfig.allowsCellularAccess          = true
        session = URLSession(configuration: sessionConfig)
        return sharedInstance
    }()
    
    private init() {}
    
    private func showHideLoading(isShow: Bool) {
        DispatchQueue.main.async {
            if isShow {
                LoadingView.show()
            }
            else {
                LoadingView.hide()
            }
        }
    }
    
    @objc private func onSessionExpired() {
        startSessionTimeout(isStart: false)
        let vc = UIViewController().VC(sbName: "LaunchScreenSB", identifier: "LaunchScreenVC") as! LaunchScreenVC
        vc.session_timeout = true
        vc.setRootViewController(viewController: vc)
    }
    
    func startSessionTimeout(isStart: Bool) {
        // Session timer
        DataAccess.timer?.invalidate()
        
        if isStart {
            DataAccess.timer = Timer.scheduledTimer(timeInterval: self.timeOutDuration,
                                                    target      : self,
                                                    selector    : #selector(self.onSessionExpired),
                                                    userInfo    : nil,
                                                    repeats     : false)
        }
    }
    
    func fetchData<I: Encodable, O: Decodable>(shouldShowLoading  : Bool = true,
                                               apiKey             : APIKey,
                                               httpMethod         : HTTPMethod = .POST,
                                               body               : I,
                                               responseType       : O.Type,
                                               completion         : @escaping (Result<O, NSError>) -> Void) {
        
        if shouldShowLoading {
            DispatchQueue.main.async {
                LoadingView.show()
            }
        }
        
        // Session timer
        self.startSessionTimeout(isStart: true)
        
        guard let request = self.getURLRequest(apiKey: apiKey, body: body) else {
            print("Sorry From DataAccess")
            return
        }
        
        DataAccess.session.dataTask(with: request) { (data, response, error) in
            
            //ShowLoadingimagView
            if shouldShowLoading {
                DispatchQueue.main.async {
                    LoadingView.hide()
                }
            }
            
            guard
                let url = response?.url,
                let httpResponse = response as? HTTPURLResponse,
                let fields = httpResponse.allHeaderFields as? [String: String]
            else {
                if let nsError = error as NSError? {
                    #if DEBUG
                    Log.e("""
                    \(apiKey) \n\(nsError.code) | \(nsError.localizedDescription)
                    """)
                    #endif
                    
                    DispatchQueue.main.async {
                        completion(.failure(nsError))
                    }
                    
                    return
                }
                else {
                    let nsError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "error_occurred_during_process".localized])
                    #if DEBUG
                    Log.e("""
                    \(apiKey) \n\(nsError.code) | \(nsError.localizedDescription)
                    """)
                    #endif
                    DispatchQueue.main.async {
                        completion(.failure(nsError))
                    }
                    
                    return
                }
            }
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
            for cookie in cookies {
                var cookieProperties = [HTTPCookiePropertyKey: Any]()
                cookieProperties[.name] = cookie.name
                cookieProperties[.value] = cookie.value
                cookieProperties[.domain] = cookie.domain
                cookieProperties[.path] = cookie.path
                cookieProperties[.version] = cookie.version
                cookieProperties[.expires] = Date().addingTimeInterval(31536000)
                
                let newCookie = HTTPCookie(properties: cookieProperties)
                HTTPCookieStorage.shared.setCookie(newCookie!)
#if DEBUG
                print("name: \(cookie.name) value: \(cookie.value)")
#endif
            }
            
            guard let data = data else {
                
                if apiKey != .WABOOKS_MREC_R010 && apiKey != .WABOOKS_MREC_R006 && apiKey != .WABOOKS_MREC_R030 {
                    
                    if apiKey == .WABOOKS_MREC_C002 { //if upload image, show differ popup descr
                        self.showUploadImgFailPopup {
                            self.fetchData(apiKey: apiKey, body: body, responseType: responseType) { (result) in
                                completion(result)
                            }
                        }
                    } else {
                        self.showNoConnection {
                            self.fetchData(apiKey: apiKey, body: body, responseType: responseType) { (result) in
                                completion(result)
                            }
                        }
                    }
                        
                    
                } else {
//                    let _ = NSError(domain: "정상적으로 로그아웃 되었습니다.", code: 1004, userInfo: [NSLocalizedDescriptionKey : "connection_is_unstable_please_try_again_later".localized])
                    Log.e("""
                                                                                \(request.url!) | \(apiKey.rawValue)
                                                                                Timeout Error.
                                                                                """)
                    
                    // Send record to Crashlytics to monitoring an error
                    self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "connection_is_unstable_please_try_again_later", domain: "Timeout Error.", code: 403, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                    
//                    DispatchQueue.main.async {
//                        completion(.failure(timeout))
//                    }
                    //New Flow Updated 28.12.21
                    self.showNoConnection {
                        self.fetchData(apiKey: apiKey, body: body, responseType: responseType) { (result) in
                            completion(result)
                        }
                    }
                }
                
                return
            }
            
            let decodedDataString = String(data: data, encoding: String.Encoding.utf8)?.removingPercentEncoding
//            decodedDataString = decodedDataString?.replace(of: "+", with: " ")
            guard let responseData = decodedDataString == nil ? data : decodedDataString?.data(using: .utf8) else {
                Log.e("""
                    \(request.url!) | \(apiKey.rawValue)
                    Could not convert string to data.
                    """)
                DispatchQueue.main.async {
                    let error = NSError(domain: "ClientError", code: 1005, userInfo: [NSLocalizedDescriptionKey : "Could not convert string to data."])
                    
                    // Send record to Crashlytics to monitoring an error
                    self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "Could not convert string to data.", domain: "ClientError", code: 1005, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                    
                    completion(.failure(error))
                }
                return
            }
            
            guard let responseObject = try? JSONDecoder().decode(Response<O>.self, from: responseData) else {
                if responseData.prettyPrinted == "{\n\n}" {
                    let htmlString = String(data: responseData, encoding: .utf8) ?? ""
                    
                    Log.e("""
                        \(request.url!) | \(apiKey.rawValue)
                        
                        Error Response:
                        \(responseData.prettyPrinted)
                        \(htmlString)
                        """)
                    
                    // Send record to Crashlytics to monitoring an error
                   self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "Could not convert string to data.", domain: "Error Response", code: 6000, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                    
                    //New Flow Updated 28.12.21
                    self.showServerError {
                        self.fetchData(apiKey: apiKey, body: body, responseType: responseType) { (result) in
                            completion(result)
                        }
                    }
                }
                else {
                    Log.e("""
                        \(request.url!) | \(apiKey.rawValue)
                        
                        Error mapping data.
                        Response:
                        \(responseData.prettyPrinted)
                        """)
                    
                    DispatchQueue.main.async {
                        let error = NSError(domain: "ClientError", code: 1005, userInfo: [NSLocalizedDescriptionKey : "error_occurred_during_process".localized])
                        Log.e(error.localizedDescription)
                        
                        // Send record to Crashlytics to monitoring an error
                        self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "error_occurred_during_process", domain: "ClientError", code: 1005, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                        
                        completion(.failure(error))
                    }
                }
                
                
                return
            }
            
            if let data = responseObject.RESP_DATA {
                Log.s("""
                    \(request.url!) | \(apiKey.rawValue)
                    \(responseData.prettyPrinted)
                    """)
                
                // Check for error RSLT_CD
                DispatchQueue.main.async {
                    if responseObject.RSLT_CD != "0000" && apiKey != .MG { // For MG ->error RSLT_CD = nil
                        let error = NSError(domain: "Webcash", code: Int((responseObject.RSLT_CD ?? "").dropFirst(2)) ?? 0, userInfo: [NSLocalizedDescriptionKey : (responseObject.RSLT_MSG ?? "").stripHTMLAndFormat()])
                        Log.e(error.localizedDescription)
                         
                        // Send record to Crashlytics to monitoring an error
                        self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: responseObject.RSLT_MSG ?? "", domain: "Webcash", code: Int((responseObject.RSLT_CD ?? "").dropFirst(2)) ?? 0, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                        
                        completion(.failure(error))
                    }
            
                    //Disconnect session from response server
                    if responseObject.RSLT_CD == "M_2001" || responseObject.RSLT_CD == "M_2002" {
                        DispatchQueue.main.async {
                          let vc = UIViewController().VC(sbName: "LoginSB", identifier: "LoginVC") as! LoginVC
                          vc.setRootViewController(viewController: vc)
                        }
                    }
                    else {
                        completion(.success(data))
                    }
                }
            }
            else {
                Log.e("""
                    \(request.url!) | \(apiKey.rawValue)
                    \(responseData.prettyPrinted)
                    """)
                 
               // Send record to Crashlytics to monitoring an error
                self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: responseObject.RSLT_MSG ?? "", domain: "Unknown Type", code: 6969, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                
                /**
                 Update: 20210122 thea
                 TODO: check errror code SES001
                 **/
                if responseObject.RSLT_CD == "SES001" {
                    
                    
//                    let isAutoLogin = MyDefaults.bool(key: .autoLogin)
//
//                    if isAutoLogin {
//                        DispatchQueue.main.async {
//                           let vc = UIViewController().VC(sbName: "LoginSB", identifier: "LoginVC") as! LoginVC
//                           vc.setRootViewController(viewController: vc)
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            let vc = UIViewController().VC(sbName: "LoginSB", identifier: "LoginVC") as! LoginVC
//                            vc.setRootViewController(viewController: vc)
//                        }
//                    }
                    // 1. Change from move to Login screen to Go to Login Screen and then autoLogin.
                    // 2. Call API Login instead of move to Login Screen.
                    // flow link : https://flow.team/l/PHQXk
                    // I choose option 2 :
                    // 2. Call API Login instead of move to Login Screen.
                    let bisKey = UserDefaults.standard.string(forKey: "bizKey") ?? ""
                    
                    CompanyVM().requestR002(bizKey: bisKey) { result in
                        switch result {
                        case .success(_) :
                            self.fetchData(apiKey: apiKey, body: body, responseType: responseType,completion: completion)
                        case .failure(let error) :
                            completion(.failure(error))
                        }
                    }

                    
                } else {
                    DispatchQueue.main.async {
                      
                        
                        // Send record to Crashlytics to monitoring an error
                        self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: responseObject.RSLT_MSG ?? "", domain: "ClientError", code: 1000, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                        
                        if responseObject.RSLT_CD == "WBW1147" {
                            let error = NSError(domain: "ClientError", code: 1147, userInfo: [NSLocalizedDescriptionKey :  ""]) //You do not have the persmission to view this post. Please contact the bullentin board administrator.
                            completion(.failure(error))
                        }else if  responseObject.RSLT_CD == "WBW1146" {
                            let error = NSError(domain: "ClientError", code: 1146, userInfo: [NSLocalizedDescriptionKey :  "".localized]) // You_can_only_delete_the_board_that_is_empty_or_have_no_post
                            completion(.failure(error))
                        }else {
                            let error = NSError(domain: "ClientError", code: 1000, userInfo: [NSLocalizedDescriptionKey : (responseObject.RSLT_MSG ?? "").stripHTMLAndFormat()])
                            completion(.failure(error))
                        }
                        
                    }
                }
            }
            
        }.resume()
    }
    
    //this method used to request New MG with Dev Server
    func fetchNewMG<I: Encodable, O: Decodable>(shouldShowLoading  : Bool = false,
                                               apiKey             : APIKey,
                                               httpMethod         : HTTPMethod = .POST,
                                               body               : I,
                                               responseType       : O.Type,
                                               completion         : @escaping (Result<O, NSError>) -> Void) {
        
        if shouldShowLoading {
            DispatchQueue.main.async {
                LoadingView.show()
            }
        }
        
        // Session timer
        self.startSessionTimeout(isStart: true)
        
        guard let request = self.getURLRequest(apiKey: apiKey, body: body, httpMethod: httpMethod) else {
            print("Sorry")
            return
        }
        
        DataAccess.session.dataTask(with: request) { (data, response, error) in
            
            //ShowLoadingimagView
            if shouldShowLoading {
                DispatchQueue.main.async {
                    LoadingView.hide()
                }
            }
            
            guard let data = data else {
                
//                let timeout = NSError(domain: "정상적으로 로그아웃 되었습니다.", code: 1004, userInfo: [NSLocalizedDescriptionKey : "connection_is_unstable_please_try_again_later".localized])
                Log.e("""
                                                                                \(request.url!) | \(apiKey.rawValue)
                                                                                Timeout Error.
                                                                                """)
                
               // Send record to Crashlytics to monitoring an error
                self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "Timeout Error.", domain: "Timeout Error.", code: 408, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                
                self.showNoConnection {
                    self.fetchNewMG(apiKey: .AppSetting, httpMethod: .GET, body: body, responseType: responseType) { result in
                        completion(result)
                    }
                }
                return
            }
            
            let decodedDataString = String(data: data, encoding: String.Encoding.utf8)?.removingPercentEncoding
            
            guard let responseData = decodedDataString == nil ? data : decodedDataString?.data(using: .utf8) else {
                Log.e("""
                    \(request.url!) | \(apiKey.rawValue)
                    Could not convert string to data.
                    """)
                
                // Send record to Crashlytics to monitoring an error
                self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "Could not convert string to data.", domain: "ClientError", code: 1005, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                
                DispatchQueue.main.async {
                    let error = NSError(domain: "ClientError", code: 1005, userInfo: [NSLocalizedDescriptionKey : "Could not convert string to data."])
                    completion(.failure(error))
                }
                return
            }
            
            guard let responseObject = try? JSONDecoder().decode(O.self, from: responseData) else {
                if responseData.prettyPrinted == "{\n\n}" {
                    let htmlString = String(data: responseData, encoding: .utf8) ?? ""
                    
                    Log.e("""
                        \(request.url!) | \(apiKey.rawValue)
                        
                        Error Response:
                        \(responseData.prettyPrinted)
                        \(htmlString)
                        """)
                    
                    // Send record to Crashlytics to monitoring an error
                    self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "Error Response.", domain: "Error Response.", code: 6000, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                    
                    self.showServerError {
                        self.fetchNewMG(apiKey: .AppSetting, httpMethod: .GET, body: body, responseType: responseType) { result in
                            completion(result)
                        }
                    }
                }
                else {
                    Log.e("""
                        \(request.url!) | \(apiKey.rawValue)
                        
                        Error mapping data.
                        Response:
                        \(responseData.prettyPrinted)
                        """)
                    
                    // Send record to Crashlytics to monitoring an error
                    self.crashlyticMonitoring(apiKey: apiKey, requestURL: "\(request.url!)", localizedDescription: "mg_service_reason", domain: "ClientError.", code: 1005, functionName: "\(#function)", errorLine: "\(#line)", filename: "\(#file)")
                    
                    DispatchQueue.main.async {
                        let error = NSError(domain: "ClientError", code: 1005, userInfo: [NSLocalizedDescriptionKey : "mg_service_reason".localized])
                        Log.e(error.localizedDescription)
                        completion(.failure(error))
                    }
                }
                
                
                
                return
            }
            
            #if DEBUG
            //Success
            Log.s("""
                    \(request.url!) | \(apiKey.rawValue)
                    \(responseData.prettyPrinted)
                    """)
            #endif
            
            completion(.success(responseObject))
            
        }.resume()
    }
    
    
    //MARK: - GET REQUEST URL -
    private func getURLRequest<T: Encodable>(apiKey: APIKey, urlStr: String = "", body: T, httpMethod : HTTPMethod = .POST) -> URLRequest? {
        var request :   URLRequest! = nil
        
        if apiKey == .AppSetting {
            let key     = MasterID.key
            let value   = MasterID.value
             
            let url = "\(APIKey.AppSettingURL)\(APIKey.AppSetting.rawValue)\(APIKey.AppID)?os=iOS"
            request             = URLRequest(url: URL(string: url)!)
            
            request.addValue(Shared.language.rawValue,      forHTTPHeaderField: "Accept-Language")
            request.addValue(APIKey.XAPPVERSION.rawValue,   forHTTPHeaderField: "X-App-Version")
            request.httpMethod = httpMethod.rawValue
            
            #if DEBUG
            Log.r("""
                \(request.url!) | \(apiKey.rawValue)
                KEY     : \(key)
                VALUE   : \(value)
                METHOD  : \(httpMethod)
                """)
            #endif
            
        } else {
            
            let queryStr = self.encodeQueryString(api: apiKey, body: body) ?? ""
            
            if let url = URL(string: Shared.c_base_url) {
                request             = URLRequest(url: url)
                request.httpBody    = queryStr.data(using: .utf8)
                
                request.httpMethod  = httpMethod.rawValue
                
                // add this : 2024.03.12
                // Update Session Time-out so need to add Authorization value
                if Shared.R002_DATA?.TOKEN_TYPE?.isEmpty ?? false {
                    let Authorization = "\(Shared.R002_DATA?.TOKEN_TYPE ?? "") \(Shared.R002_DATA?.ACCESS_TOKEN ?? "")"
                    request.addValue(Authorization,                  forHTTPHeaderField: "Authorization")
                }
               
                request.addValue(Shared.language.rawValue,      forHTTPHeaderField: "Accept-Language")
                request.addValue(APIKey.XAPPVERSION.rawValue,   forHTTPHeaderField: "X-App-Version")
                
                // WebView Error if put content type = application/json
                request.addValue("application/json",            forHTTPHeaderField: "Content-Type")
                
                guard let cookies = HTTPCookieStorage.shared.cookies(for: url) else {
                    return request
                }

                request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
                
                #if DEBUG
                
                /**
                 DONOT PRINT FOR API:
                 - WABOOKS_MREC_C002 : upload image
                 - WABOOKS_MREC_C003 : create receipt
                 - WABOOKS_MREC_C004 : update receipt
                 */
                if (apiKey != .WABOOKS_MREC_C002) || (apiKey != .WABOOKS_MREC_C003) || (apiKey != .WABOOKS_MREC_C004) {
                    Log.r("""
                            \(request.url!) | \(apiKey.rawValue)
                            \(queryStr)
                            \((request?.allHTTPHeaderFields)!)
                            """)
                }
                
                #endif
            }
            
        }
        
        return request
    }
    
    // MARK: - Download Task
    /** Download data with download task and response data & error as completion */
    func downloadTask(withURL urlString: String?,shouldShowLoading: Bool = false, completion: @escaping (Data?, Error?) -> Void) {
        
        let encodeURL = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // 1 : is Valid URL
        guard let url = URL(string: encodeURL ?? "") else { return }
        
        
        if shouldShowLoading {
            DispatchQueue.main.async {
                LoadingView.show()
            }
        }
        
        // 3 : Get activeDownloads
        let activeDownload = activeDownloads[url]
        
        if let download = activeDownload {
            
            guard let data = download.data else {
                
                // 4. Resume data
                if let resumeData = download.resumeData {
                    download.task = DataAccess.session.downloadTask(withResumeData: resumeData, completionHandler: { (locationUrl, response, error) in
                        self.downloaded(download, downloadUrl: url, didFinishDownloadingTo: locationUrl, completion: { (data, error) in
                            download.resumeData = nil
                            
                            if shouldShowLoading {
                                DispatchQueue.main.async {
                                    LoadingView.hide()
                                }
                            }
                            completion(data,error)
                        })
                    })
                    
                    download.task?.resume()
                    download.isDownloading = true
                }
                // 5. No resume data
                else {
                    download.task = DataAccess.session.downloadTask(with: url, completionHandler: { (locationUrl, response, error) in
                        
                        
                        //ShowLoadingimagView
                        if shouldShowLoading {
                            DispatchQueue.main.async {
                                LoadingView.hide()
                            }
                        }
                        
                        self.downloaded(download, downloadUrl: url, didFinishDownloadingTo: locationUrl, completion: { (data, error) in
                            if shouldShowLoading {
                                DispatchQueue.main.async {
                                    LoadingView.hide()
                                }
                            }
                            completion(data,error)
                        })
                    })
                    
                    download.task?.resume()
                    download.isDownloading = true
                }
                return
            }
            // 6. Completed download data
            
            if shouldShowLoading {
                DispatchQueue.main.async {
                    LoadingView.hide()
                }
            }
            completion(data, nil)
            
        }
        else {
            
            // 1 : init new Download
            let download = Download()
            
            // 2 : download new data
            download.task = DataAccess.session.downloadTask(with: url) { (locationUrl, response, error) in
                self.downloaded(download, downloadUrl: url, didFinishDownloadingTo: locationUrl, completion: { (data, error) in
                    //ShowLoadingimagView
                    if shouldShowLoading {
                        DispatchQueue.main.async {
                            LoadingView.hide()
                        }
                    }
                    completion(data,error)
                })
            }
            
            download.task?.resume()
            download.isDownloading = true
            self.activeDownloads[url] = download
        }
    }
    
    // Stores downloaded file
    private func downloaded(_ download: Download, downloadUrl: URL, didFinishDownloadingTo locationUrl: URL?, completion: @escaping (Data?, Error?) -> Void) {
        
        // 1
        
        // 2
        guard let location = locationUrl else { return }
        
        // 3
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsPath.appendingPathComponent(downloadUrl.lastPathComponent)
        
        // 4
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            let data = try Data.init(contentsOf: destinationURL)
            download.isDownloading = false
            download.data = data
            completion(data, nil)
        } catch let error {
            completion(nil,error)
        }
        
    }
    
    func pauseDownload(_ urlString: String?) {
        
        guard let url = URL(string: urlString ?? "") else { return }
        guard let download = activeDownloads[url] else { return }
        
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
}

extension DataAccess {
    /// Encode the Model Object to JSON String
    ///
    /// - Parameters:
    ///   - api: API key
    ///   - body: Model Object that conform to **Encodable** protocol
    /// - Returns: Encoded String if can encode, otherwise nil
    private func encodeQueryString<T: Encodable>(api: APIKey, body: T) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let NTNL_CD         = "VN"
        
        if api != APIKey.BOARD_DETAIL_LIST_R001 {
            
            let request = Request<T>(
                API_CRTS_KEY : APIKey.AUTHENTICATION_KEY,
                API_SVC_ID   : api.rawValue,
                TIME_ZONE    : TimeZone.current.identifier,
                USER_ID      : Shared.R002_DATA?.USER_ID ?? "",
                REQ_DATA     : body,
                NTNL_CD      : NTNL_CD
            )
            
            guard let data = try? encoder.encode(request), let jsonData = String(data: data, encoding: .utf8) else {
                return nil
            }
            return jsonData
        }
        else {
            // MARK: BOARD_DETAIL_LIST_R001
            var str_ptl_id = ""
            #if DEBUG
            str_ptl_id = "PTL_51"
            #else
            str_ptl_id = "PTL_3"
            #endif
            
            let request = AlarmRequest<T>(
                _tran_cd: api.rawValue,
                _ptl_id: str_ptl_id, // For Real Version  PTL_3 || For Develop Version PTL_51
                _chnl_id: "CHNL_40",
                _lngg_dsnc: "DF",
                _req_data: body
            )
            
            guard let data = try? encoder.encode(request), let jsonData = String(data: data, encoding: .utf8) else {
                return nil
            }
            return jsonData
        }
    }
    /// Replace any special characters with URL-friendly characters
    ///
    /// - Parameter string: String to encode
    /// - Returns: A new string created by replacing all characters with URL-friendly characters
    private func encode(_ string: String) -> String? {
        let allowedCharacterSets = (NSCharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSets.removeCharacters(in: "!@#$%^&*()-_+=~`:;\"'<,>.?/")
        guard let encodeString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSets as CharacterSet) else{
            return nil
        }
        return encodeString
    }
    
    private func JSONStringify(value: Any, prettyPrinted: Bool = false) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: options!) {
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    private func jsonToDic(_ data: Data) throws -> NSDictionary{
        enum JSONError: Error {
            case serializedJSONError // dic -> JSON
            case deserializedJSONError
        }
        
        guard let dic: NSDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else{
            throw JSONError.deserializedJSONError
        }
        
        return dic
    }
    
    private func crashlyticMonitoring(apiKey: APIKey, requestURL: String, localizedDescription: String, domain: String, code: Int, functionName: String, errorLine: String, filename: String) {
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(localizedDescription.localized, comment: ""),
                        "USER_ID"       : Shared.user_id,
                        "API_KEY"       : apiKey.rawValue,
                        "URL"           : requestURL,
                        "FILE_NAME"     : filename,
                        "ERROR_LINE"    : errorLine,
                        "FUNCTION"      : functionName] as [String : Any]
        
        let errorInfo = NSError(domain: domain, code: code, userInfo: userInfo)
        Crashlytics.crashlytics().record(error: errorInfo)
    }
}


extension DataAccess {
    
    func showUploadImgFailPopup(completion: @escaping Completion) {
        DispatchQueue.main.async {
            
            if let activeVC = UIApplication.activeVC() {
                activeVC.customAlert(type: .CONFIRM_ALERT,
                                     image: "badge_failed",
                                     title: "uploaded_fail".localized,
                                     message: "uploaded_fail_descr".localized,
                                     redTitle: "", greyTitle: "try_again".localized) { (_) in
                    completion()
                }
            }
            
        }
    }
    
    func showNoConnection(completion: @escaping Completion) {
        DispatchQueue.main.async {
            
            if let activeVC = UIApplication.activeVC() {
                activeVC.customAlert(type: .CONFIRM_ALERT,
                                     image: "badge_failed",
                                     title: "notice".localized,
                                     message: "connection_is_unstable_please_try_again_later".localized,
                                     redTitle: "", greyTitle: "try_again".localized) { (_) in
                    completion()
                }
            }
            
        }
    }
    
    func showServerError(completion: @escaping Completion) {
        DispatchQueue.main.async {
            if let activeVC = UIApplication.activeVC() {
                activeVC.customAlert(type: .CONFIRM_ALERT,
                                     image: "badge_failed",
                                     title: "notice".localized,
                                     message: "error_occurred_during_process".localized,
                                     redTitle: "", greyTitle: "try_again".localized) { (_) in
                    completion()
                }
            }
        }
    }
}


extension UIApplication {
 
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        
        return viewController
    }
    
    class func activeVC() -> UIViewController? {
        var topController: UIViewController = UIApplication.shared.keyWindowInConnectedScenes!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        
        return topController
    }
}
