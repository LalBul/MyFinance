//
//  Budget.swift
//  MyFinance
//
//  Created by Вова Сербин on 13.04.2022.
//

import Foundation
import RealmSwift

class Budget: Object {
    @objc dynamic var collected: Double = 0
    let history = List<HistoryBudget>()
}
