//
//  Images.swift
//  Aswachh Bharat
//
//  Created by Sakthi Ganesh on 06/08/16.
//  Copyright © 2016 devup. All rights reserved.
//

import Foundation
import Alamofire

enum ImageRouter : URLRequestConvertible {
    
    static let baseURL = "http://aswachhbharat.org/api/"
    
    case All
    case Get(Int)
    
    var URLRequest: NSMutableURLRequest {
        var method: Alamofire.Method {
            switch self {
            case .Get:
                return .GET
            default:
                return .GET
            }
        }
        
        let params: ([String:AnyObject]?) = {
            switch self {
            case .Get(_):
                return nil
            default:
                return nil
            }
        }()
        
        let url:NSURL = {
            // build up and return the URL for each endpoint
            let relativePath:String?
            switch self {
            case .Get(let id):
                relativePath = "images/\(id)"
            default:
                relativePath = "images/"
            }
            
            var URL = NSURL(string: ImageRouter.baseURL)!
            if let relativePath = relativePath {
                URL = URL.URLByAppendingPathComponent(relativePath)
            }
            return URL
        }()
        
        let URLRequest = NSMutableURLRequest(URL: url)
        
        let encoding = Alamofire.ParameterEncoding.JSON
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: params)
        
        encodedRequest.HTTPMethod = method.rawValue
        
        return encodedRequest
    }
    
}