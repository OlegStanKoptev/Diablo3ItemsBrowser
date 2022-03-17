//
//  CodingUserInfoKey+Extension.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 11.03.2022.
//

import Foundation

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
    static let itemTypeForItem = CodingUserInfoKey(rawValue: "itemTypeForItem")!
}
