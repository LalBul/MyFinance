//
//  HistoryItem.swift
//  MyFinance
//
//  Created by Вова Сербин on 03.07.2021.
//

import Foundation
import RealmSwift

class HistoryItems: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var date: Date?
    @objc dynamic var amount: Double = 0
}
