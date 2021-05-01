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

public protocol RRCMEncoding: ParameterEncoding { }
extension URLEncoding: RRCMEncoding { }

public enum RRCMNetworkError: Error {
    case badDecode
    case emptyResponse
    case badRequest
    case serverError
}

open class RRCMNetwork {
    
    private var baseurl: String
    
    public init(baseurl: String) {
        self.baseurl = baseurl
    }
    
    private func url(_ request: RRCMNetworkRequest) -> URL {
        return URL(string: self.baseurl + request.path)!
    }

    
    public func requestJSON(_ request: RRCMNetworkRequest) -> Observable<JSON> {
        
        return Observable<JSON>.create { (observer) -> Disposable in
            
            let request = Alamofire.request(
                self.url(request),
                method: HTTPMethod(rawValue: request.method.rawValue)!,
                parameters: request.parameters,
                encoding: request.encoding,
                headers: request.headers).responseJSON { (response) in
                    if (response.result.isSuccess) {
                        guard let value = response.value else {
                            observer.onError(RRCMNetworkError.emptyResponse)
                            return
                        }
                        observer.onNext(JSON(value))
                        observer.onCompleted()
                    } else {
                        observer.onError(response.error!)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
        
    }
    
    public func requestData<M: Codable>(_ request: RRCMNetworkRequest, type: M.Type) -> Observable<M> {
        
        return Observable<M>.create { (observer) -> Disposable in
                        
            let request = Alamofire.request(
                self.url(request),
                method: HTTPMethod(rawValue: request.method.rawValue)!,
                parameters: request.parameters,
                encoding: request.encoding,
                headers: request.headers).responseData { (response) in
                    
                    if (response.result.isSuccess) {
                        do {
                            let model = try JSONDecoder().decode(M.self, from: response.value!)
                            observer.onNext(model)
                            observer.onCompleted()
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

public class RRCMNetworkRequest: NSObject {
    
    var path: String
    var method: RRCMNetworkMethod
    var parameters: [String: Any]?
    var headers: [String: String]?
    var encoding: RRCMEncoding
    
    public init(path: String,
                method: RRCMNetworkMethod,
                parameters: [String: Any]?,
                headers: [String: String]?,
                encoding: RRCMEncoding = URLEncoding.default) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.encoding = encoding
    }
    
}
