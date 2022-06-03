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
    @objc dynamic var currency: String = ""
    
    @objc dynamic var amount: Double = 0
    @objc dynamic var amountInUS: Double = 0
    @objc dynamic var amountInEU: Double = 0
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "history")
    
    func addCurrencyMoney(currency: String, amount: Double) {
        if currency == "₽" {
            self.amount = amount
            self.amountInUS = amount / 80
            self.amountInEU = amount / 90
        } else if currency == "Є" {
            self.amount = amount * 90
            self.amountInUS = amount * 1.10
            self.amountInEU = amount
        } else if currency == "$" {
            self.amount = amount * 80
            self.amountInUS = amount
            self.amountInEU = amount * 0.90
        }
    }

}
