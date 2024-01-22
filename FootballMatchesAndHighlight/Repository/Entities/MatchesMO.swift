//
//  MatchesMO.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 17/01/2024.
//

import Foundation
import CoreData

@objc(MatchesMO)
public class MatchesMO: NSManagedObject { }

extension MatchesMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchesMO> {
        return NSFetchRequest<MatchesMO>(entityName: "MatchesMO")
    }
    
    @NSManaged public var date: String?
    @NSManaged public var matchDescription: String?
    @NSManaged public var home: String?
    @NSManaged public var away: String?
    @NSManaged public var winner: String?
    @NSManaged public var highlights: String?

}

extension MatchesMO : Identifiable { }

extension MatchesMO: DomainModelProtocol {
    
    func toDomainModel() -> Matches {
        return Matches(
            date: date,
            description: matchDescription,
            home: home,
            away: away,
            winner: winner,
            highlights: highlights
        )
    }
}
