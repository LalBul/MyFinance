//
//  HistoryBudget.swift
//  MyFinance
//
//  Created by Вова Сербин on 06.04.2022.
//

import Foundation
import RealmSwift

class HistoryBudget: Object {
    
    
    @objc dynamic var operation: String = ""
    @objc dynamic var date: Date = Date() {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateDay = dateFormatter.string(from: date)
            
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "MM-yyyy"
            dateMonth = dateFormatter1.string(from: date)
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "yyyy"
            dateYear = dateFormatter2.string(from: date)
        }
    }
    @objc dynamic var currency: String = ""
    
    @objc dynamic var sum: Double = 0
    @objc dynamic var sumInUS: Double = 0
    @objc dynamic var sumInEU: Double = 0
    
    func addCurrencyMoney(currency: String, amount: Double) {
        
        if currency == "₽" {
            self.sum = amount
            self.sumInUS = amount / 80
            self.sumInEU = amount / 90
        } else if currency == "Є" {
            self.sum = amount * 90
            self.sumInUS = amount * 1.10
            self.sumInEU = amount
        } else if currency == "$" {
            self.sum = amount * 80
            self.sumInUS = amount
            self.sumInEU = amount * 0.90
        }
    }

    
    @objc dynamic var dateDay: String = ""
    @objc dynamic var dateMonth: String = ""
    @objc dynamic var dateYear: String = ""
    
    var parentBudget = LinkingObjects(fromType: Budget.self, property: "history")
  

}
