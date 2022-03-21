//
//  ItemDescription.swift
//  Diablo3ItemsBrowser
//
//  Created by Oleg Koptev on 10.03.2022.
//

import Foundation
import CoreData

@objc(ItemDescription)
public class ItemDescription: NSManagedObject, Decodable {
    enum CodingKeys: CodingKey {
        case accountBound
        case armor
        case color
        case damage
        case dps
        case flavorText
        case flavorTextHtml
        case icon
        case id
        case isSeasonRequiredToDrop
        case name
        case requiredLevel
        case seasonRequiredToDrop
        case setDescription
        case setDescriptionHtml
        case setName
        case slug
        case stackSizeMax
        case tooltipParams
        case typeName
    }

    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError()
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.accountBound = try container.decode(Bool.self, forKey: .accountBound)
        self.armor = try container.decodeIfPresent(String.self, forKey: .armor)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
        self.damage = try container.decodeIfPresent(String.self, forKey: .damage)
        self.dps = try container.decodeIfPresent(String.self, forKey: .dps)
        self.flavorText = try container.decodeIfPresent(String.self, forKey: .flavorText)
        self.flavorTextHtml = try container.decodeIfPresent(String.self, forKey: .flavorTextHtml)
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.id = try container.decode(String.self, forKey: .id)
        self.isSeasonRequiredToDrop = try container.decode(Bool.self, forKey: .isSeasonRequiredToDrop)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.requiredLevel = try container.decode(Int32.self, forKey: .requiredLevel)
        self.seasonRequiredToDrop = try container.decode(Int32.self, forKey: .seasonRequiredToDrop)
        self.setDescription = try container.decodeIfPresent(String.self, forKey: .setDescription)
        self.setDescriptionHtml = try container.decodeIfPresent(String.self, forKey: .setDescriptionHtml)
        self.setName = try container.decodeIfPresent(String.self, forKey: .setName)
        self.slug = try container.decodeIfPresent(String.self, forKey: .slug)
        self.stackSizeMax = try container.decode(Int32.self, forKey: .stackSizeMax)
        self.tooltipParams = try container.decodeIfPresent(String.self, forKey: .tooltipParams)
        self.typeName = try container.decodeIfPresent(String.self, forKey: .typeName)
    }
}

extension ItemDescription {
    func getDescriptionAsKeyAndValue() -> [(String, String)] {
        let result: [(String, String?)] = [
            ("Name", name),
            ("Id", id),
            ("Set Name", setName),
            ("Set Description", formattedSetDescription(setDescription)),
            ("Armor", armor),
            ("Damage", damage),
            ("DPS", dps),
            ("Required Level", "\(requiredLevel)"),
            ("Stack Size Max", "\(stackSizeMax)"),
            ("Flavor Text", flavorText),
        ]
        
        return result.compactMap { (key, optionalValue) in
            if let value = optionalValue { return (key, value) }
            return nil
        }
    }
    
    /// Set Description sometimes doesn't have newline symbols, as they should be (presented in html version).
    /// This method adds missing newline symbols.
    /// - Parameter description: Set Description to be formatted
    /// - Returns: Set Descriptions with added newline symbols before set's numbers
    private func formattedSetDescription(_ description: String?) -> String? {
        guard let description = description else { return nil }
        let regex = try! NSRegularExpression(pattern: #"(?<!n|^)\("#, options: NSRegularExpression.Options.caseInsensitive)
        let range = NSMakeRange(0, description.count)
        let modString = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "\n(")
        return modString
    }
}
