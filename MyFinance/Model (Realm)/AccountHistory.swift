//
//  AccountHistory.swift
//  MyFinance
//
//  Created by Вова Сербин on 17.04.2022.
//

import Foundation
import RealmSwift

class AccountHistory: Object {
    @objc dynamic var sum: Double = 0
    @objc dynamic var operation: String = ""
    @objc dynamic var date: Date = Date()
    var accountHistory = LinkingObjects(fromType: Account.self, property: "history")
}
