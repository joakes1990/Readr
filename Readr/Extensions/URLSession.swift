//
//  URLSession.swift
//  Readr
//
//  Created by Justin Oakes on 9/7/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

extension URLSession {
    
    public typealias Completion = (Data?, URLResponse?, Error?) -> Void
    
    func getReturnedDataFrom(url: URL, completion: @escaping Completion) {
        let task: URLSessionDataTask = self.dataTask(with: url, completionHandler: completion)
        task.resume()
    }

}
