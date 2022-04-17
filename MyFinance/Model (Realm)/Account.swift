//
//  Account.swift
//  MyFinance
//
//  Created by Вова Сербин on 10.04.2022.
//

import Foundation
import RealmSwift

class Account: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var collected: Double = 0
    @objc dynamic var currency: String = ""
    let history = List<AccountHistory>()
}
