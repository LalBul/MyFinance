//
//  Items.swift
//  MyFinance
//
//  Created by Вова Сербин on 01.05.2021.
//

import Foundation
import RealmSwift

class Item: Object {
    
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
    @objc dynamic var isBudget: Bool = false
    @objc dynamic var isAccount: Bool = false
    
    @objc dynamic var dateDay: String = ""
    @objc dynamic var dateMonth: String = ""
    @objc dynamic var dateYear: String = ""
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")

}
