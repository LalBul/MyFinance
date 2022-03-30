//
//  MainFinanceViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 29.03.2022.
//

import Foundation
import UIKit

class MainFinanceViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        financeView.layer.cornerRadius = 10
    }
    
    
    @IBOutlet weak var financeView: UIView!
    
    
}
