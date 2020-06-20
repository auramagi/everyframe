//
//  String+case.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/19.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

extension String {
    func transformingSnakeCaseToHumanReadable() -> String {
        let result = replacingOccurrences(of: "_", with: " ").capitalized
        return result
    }
}
