//
//  TeamMO.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 17/01/2024.
//

import Foundation
import CoreData


@objc(TeamMO)
public class TeamMO: NSManagedObject {}

extension TeamMO {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamMO> {
    return NSFetchRequest<TeamMO>(entityName: "TeamMO")
  }
  
  @NSManaged public var id: String?
  @NSManaged public var name: String?
  @NSManaged public var logo: String?
  @NSManaged public var isSelectedFilter: Bool
}

extension TeamMO : Identifiable { }

extension TeamMO: DomainModelProtocol {
  func toDomainModel() -> Team {
    return Team(id: id ?? "",
                name: name ?? "",
                logo: logo ?? "",
                isSelected: isSelectedFilter)
  }
}
