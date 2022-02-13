//
//  MoneyBox.swift
//  MyFinance
//
//  Created by Вова Сербин on 20.11.2021.
//

import Foundation
import RealmSwift

class MoneyBox: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var purpose: Double = 0
    @objc dynamic var collected: Double = 0
}
