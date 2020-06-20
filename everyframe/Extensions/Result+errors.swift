//
//  Result+errors.swift
//  everyframe
//
//  Created by Mikhail Apurin on 21.06.2020.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

extension Result {
    func unwrap(onFailure: ((Failure) -> Void)?, onSuccess: (Success) -> Void) {
        switch self {
        case let .failure(failure):
            onFailure?(failure)
            
        case let .success(success):
            onSuccess(success)
        }
    }
}
