//
//  HistoryBudget.swift
//  MyFinance
//
//  Created by Вова Сербин on 06.04.2022.
//

import Foundation
import RealmSwift

class HistoryBudget: Object {
    @objc dynamic var sum: Double = 0
    @objc dynamic var operation: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var dateDay: String = ""
    @objc dynamic var dateMonth: String = ""
    @objc dynamic var dateYear: String = ""

    func getDateDay() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateDay = dateFormatter.string(from: date)
    }
    
    func getDateMonth() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy"
        dateMonth = dateFormatter.string(from: date)
    }
    
    func getDateYear() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateYear = dateFormatter.string(from: date)
    }
    
}
