//
//  Notification.swift
//  MyFinance
//
//  Created by Вова Сербин on 03.04.2022.
//

import Foundation
import RealmSwift

class Notification: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var sum: Double = 0
    @objc dynamic var date: Date?
    @objc dynamic var done: Bool = false
}

