//
//  HistoryCell.swift
//  MyFinance
//
//  Created by Вова Сербин on 03.07.2021.
//

import UIKit
import SwipeCellKit
import RealmSwift

class HistoryCell: SwipeTableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var view: UIView!
}

