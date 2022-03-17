//
//  ItemType.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import Foundation
import CoreData

@objc(ItemType)
public class ItemType: NSManagedObject, Decodable {
    enum CodingKeys: CodingKey {
       case id, name, path
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError()
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.itemsCount = 0
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.path = try container.decode(String.self, forKey: .path)
    }
    
    var areItemsNotLoaded: Bool {
        itemsCount == 0
    }
    
    static let path = "item-type"
}
