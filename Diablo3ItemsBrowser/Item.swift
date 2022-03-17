//
//  Item.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject, Decodable {
    enum CodingKeys: CodingKey {
        case icon, id, name, path, slug
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext,
              let itemTypeId = decoder.userInfo[.itemTypeForItem] as? String else {
//          throw DecoderConfigurationError.missingManagedObjectContext
            fatalError()
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.itemType = itemTypeId
        self.icon = try container.decode(String.self, forKey: .icon)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.path = try container.decode(String.self, forKey: .path)
        self.slug = try container.decode(String.self, forKey: .slug)
    }
}
