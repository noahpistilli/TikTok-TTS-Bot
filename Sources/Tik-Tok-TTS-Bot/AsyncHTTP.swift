//
//  AsyncHTTP.swift
//  
//
//  Created by Noah Pistilli on 2022-05-05.
//

#if os(Linux)
import FoundationNetworking
#endif

import Foundation

func HTTPRequest(
    _ request: URLRequest,
    completion: @escaping (Data?, HTTPURLResponse, Error?) -> Void
) {
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        let response = response as! HTTPURLResponse
        
        if error != nil {
            completion(nil, response, error)
        } else {
            completion(data, response, nil)
        }
    }
    
    task.resume()
}

/**
 AsyncHTTPRequest exists because FoundationNetworking, which is the Networking module
 in Linux, does not have native async URLSession. This hacks around that by using
`withCheckedThrowingContinuation` to asynchronously make the network request.
 **/
func AsyncHTTPRequest(
    _ request: URLRequest
) async throws -> Data? {
     return try await withCheckedThrowingContinuation({ continuation in
        HTTPRequest(request) { data, _, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: data)
            }
        }
    })
}
