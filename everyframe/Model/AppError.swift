//
//  AppError.swift
//  everyframe
//
//  Created by Mikhail Apurin on 21.06.2020.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

struct AppError: Error {
    let string: String
    let underlying: Error?
}
