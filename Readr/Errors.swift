//
//  Errors.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/5/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

public let couldnotFindUserInfo: Error = oklasoftError(errorCode: 1015,
                                                        userInfo: nil,
                                                        localizedDescription: "A requiered user info dictionary could not be retrieved from a notification")
public let unrecognizableDataError: oklasoftError = oklasoftError(errorCode: 1016,
                                                           userInfo: nil,
                                                           localizedDescription: "Data returned by server was not recognizable for use by the application")
public let invalidURLError: oklasoftError = oklasoftError(errorCode: 1017,
                                                          userInfo: nil,
                                                          localizedDescription: "This is not a valid URL")

public struct oklasoftError: Error {
    let domain: String = "com.oklasoft"
    var errorCode: Int
    var userInfo: [AnyHashable : Any]?
    var localizedDescription: String
    
    public init(errorCode: Int, userInfo: [AnyHashable : Any]?, localizedDescription: String) {
        self.errorCode = errorCode
        self.userInfo = userInfo
        self.localizedDescription = localizedDescription
    }
    
    public func toError() -> Error {
        let newError: NSError = NSError(domain: domain,
                                        code: errorCode,
                                        userInfo: (userInfo as? [String:Any]) ?? ["":""])
        return newError as Error
    }
}
