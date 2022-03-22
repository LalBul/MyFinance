//
//  CollectionCell.swift
//  MyFinance
//
//  Created by Вова Сербин on 19.11.2021.
//

import UIKit

protocol DataCollectionProtocol {

    func deleteData(index: Int)
}

class MoneyBoxCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var purpose: UILabel!
    @IBOutlet weak var collected: UILabel!
    @IBOutlet weak var view: UIView!
    
    var delegate: DataCollectionProtocol?
    var index: IndexPath?
    
    @IBAction func deleteButton(_ sender: UIButton) {
        delegate?.deleteData(index: index!.row)
    }
    
}
