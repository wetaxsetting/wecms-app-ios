//
//  MainTabBarVM.swift
//  WABOOKS_iOS_V2
//
//  Created by Mok Monita on 15/1/21.
//

import Foundation

class MainTabBarVM {
    
    var reponseImage: WABOOKS_MREC_C002.RESPONSE?
    var documentNo  = [String]()
    
    func uploadImage(body: WABOOKS_MREC_C002.REQUEST, completion: @escaping (NSError?) -> ()) {
        DataAccess.shared.fetchData(apiKey      : .WABOOKS_MREC_C002,
                                    body        : body,
                                    responseType: WABOOKS_MREC_C002.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.reponseImage = data
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func requestDocNoWithOperationQueue(completion: @escaping () -> Void) {
        documentNo.removeAll()
        let ENV_SET_INF = ["00071", "00072", "00073"]
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1 // Ensure sequential execution

        for value in ENV_SET_INF {
            operationQueue.addOperation {
                let semaphore = DispatchSemaphore(value: 0) // To wait for async completion
                self.checkProjectSite(body: WABOOKS_MREC_R012.REQUEST(ENV_SET_INF: value)) { error in
                    if let error = error {
                        print("Error for \(value): \(error.localizedDescription)")
                    } else {
                        print("Request succeeded for \(value)")
                    }

                    // Notify delegate or closure about data update
                    DispatchQueue.main.async {
                        self.getDocNo() // Update the data source
                    }
                    semaphore.signal()
                }
                semaphore.wait() // Wait for the async task to complete
            }
        }

        operationQueue.addBarrierBlock {
            completion() // Notify when all requests are complete
        }
    }
    
    func checkProjectSite(body: WABOOKS_MREC_R012.REQUEST, completion: @escaping (NSError?) -> Void) {
        DataAccess.shared.fetchData(shouldShowLoading: false, apiKey: .WABOOKS_MREC_R012, body: body, responseType: WABOOKS_MREC_R012.RESPONSE.self) { (result) in
            switch result {
            case .success(let data):
                self.getDocNoArray(responseR012: data)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func getDocNoArray(responseR012: WABOOKS_MREC_R012.RESPONSE?) {
        documentNo.append(responseR012?.ENV_SET_CONT ?? "")
        if documentNo.count == 2 {
            let formattedDate = getCurrentDate(using: documentNo.last ?? "")
            documentNo.removeLast()
            documentNo.append(formattedDate)
        }
        
    }
    
    func getDocNo() {
        let document_no = documentNo.joined(separator: "_") // Join the array elements with an underscore
        documentNo.removeAll()
        documentNo.append(document_no)
        Shared.documentNo = documentNo.last ?? ""
        
    }
    
    func getCurrentDate(using format: String) -> String {
        let dateFormatter = DateFormatter()
        
        // Convert the custom format to a proper date format
        var correctedFormat = format
        correctedFormat = correctedFormat.replacingOccurrences(of: "YY", with: "yy") // 2-digit year
        correctedFormat = correctedFormat.replacingOccurrences(of: "MM", with: "MM") // Month
        correctedFormat = correctedFormat.replacingOccurrences(of: "DD", with: "dd") // Day
        
        dateFormatter.dateFormat = correctedFormat // Set the corrected format
        let currentDate = Date()
        return dateFormatter.string(from: currentDate) // Format current date
    }
    
}
