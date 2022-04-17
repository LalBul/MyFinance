//
//  AccountCell.swift
//  MyFinance
//
//  Created by Вова Сербин on 14.04.2022.
//

import UIKit

class AccountCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var collected: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var view: UIView!
    
    var delegate: DataCollectionProtocol?
    var index: IndexPath?
    
    @IBAction func deleteButton(_ sender: UIButton) {
        delegate?.deleteData(index: index!.row)
    }
    
}
