//
//  Array+Joined.swift
//  Rooster voor Zermelo
//
//  Created by Wisse Hes on 10/02/2023.
//

import Foundation

enum JoinType: String {
    /**
     separator: ","
     */
    case minimal = ","
    /**
     separator: ", " (with a space after the comma)
     */
    case normal = ", "
}

extension Array where Element == String {
    /**
     This is the same as `Array<String>.joined(separator: ", ")` but i'm just too lazy to type that everywhere.
     */
    func join(_ type: JoinType = .normal) -> String  {
        return self.joined(separator: type.rawValue)
    }
}
