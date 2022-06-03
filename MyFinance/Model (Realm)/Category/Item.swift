//
//  Items.swift
//  MyFinance
//
//  Created by Вова Сербин on 01.05.2021.
//

import Foundation
import RealmSwift

class Item: Object {
    
    let defaults = UserDefaults.standard
    
    @objc dynamic var title: String = ""
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
    
    @objc dynamic var amount: Double = 0
    @objc dynamic var amountInUS: Double = 0
    @objc dynamic var amountInEU: Double = 0
    
    func addCurrencyMoney(currency: String, amount: Double) {
        
        let defaultValue = defaults.double(forKey: "Limit")
        if defaults.double(forKey: "Limit") > 0 || defaults.double(forKey: "Limit") < 0  {
            if currency == "$" {
                defaults.setValue(defaultValue-amount * 80, forKey: "Limit")
            } else if currency == "Є" {
                defaults.setValue(defaultValue-amount * 90, forKey: "Limit")
            } else if currency == "₽" {
                defaults.setValue(defaultValue-amount, forKey: "Limit")
            }
        }
        
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

    @objc dynamic var isBudget: Bool = false
    @objc dynamic var isAccount: Bool = false
    
    @objc dynamic var dateDay: String = ""
    @objc dynamic var dateMonth: String = ""
    @objc dynamic var dateYear: String = ""
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")

}
