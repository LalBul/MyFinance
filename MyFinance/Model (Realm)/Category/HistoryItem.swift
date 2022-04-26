//
//  HistoryItem.swift
//  MyFinance
//
//  Created by Вова Сербин on 03.07.2021.
//

import Foundation
import RealmSwift

class HistoryItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var date: Date?
    @objc dynamic var amount: Double = 0
    //var parentCategory = LinkingObjects(fromType: Category.self, property: "history")
}
