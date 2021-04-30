//
//  ViewController.swift
//  CyxbsMobileSwift
//
//  Created by 方昱恒 on 2021/4/29.
//


import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

public enum RRCMNetworkMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public enum RRCMNetworkError: Error {
    case badDecode
    case badRequest
    case serverError
}

public class RRCMNetwork<M: Codable> {
    
    var baseurl: String
    
    public init(baseurl: String) {
        self.baseurl = baseurl
    }
    
    public func request(_ path: String, method: RRCMNetworkMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) -> Observable<M> {
        
        
        return Observable<M>.create { (observer) -> Disposable in
            
            let url = URL(string: self.baseurl + path)!
            
            let request = Alamofire.request(url, method: HTTPMethod(rawValue: method.rawValue)!, parameters: parameters, encoding: encoding, headers: headers).responseData { (response) in
                
                if (response.result.isSuccess) {
                    do {
                        let model = try JSONDecoder().decode(M.self, from: response.value!)
                        observer.onNext(model)
                    } catch {
                        observer.onError(RRCMNetworkError.badDecode)
                    }
                } else {
                    observer.onError(response.error!)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
}
