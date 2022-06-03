//
//  AddAccountViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 10.04.2022.
//

import UIKit
import RealmSwift

class AddAccountViewController: UIViewController {
    
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var addAccountOutlet: UIButton!
    @IBOutlet var currencyButton: [UIButton]!
    
    var selectedCurrency: String = ""
    
    let realm = try! Realm()
    weak var delegate: MainFinanceViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        addHaptic()
        
        addAccountOutlet.layer.cornerRadius = 10
        addAccountOutlet.isEnabled = false
        addAccountOutlet.alpha = 0.5
        
        accountName.layer.cornerRadius = 10
        
        for i in currencyButton {
            i.layer.cornerRadius = i.frame.size.height / 2
        }
       
    }
    

 
    @IBAction func addAccount(_ sender: UIButton) {
        addHaptic()
        do {
            try realm.write({
                let newAccount = Account()
                newAccount.currency = selectedCurrency
                if accountName.text != "" {
                    newAccount.title = accountName.text ?? ""
                } else {newAccount.title = "Счет"}
                newAccount.collected = 0
                realm.add(newAccount)
                delegate?.update()
                dismiss(animated: true)
            })
        } catch {
            print(error)
        }
    }
    
  
    @IBAction func currencyButtons(_ sender: UIButton) {
        addHaptic()
        for i in currencyButton {
            i.backgroundColor = .white
        }
        sender.backgroundColor = .clear
        if sender.tag == 1 {
            selectedCurrency = "$"
        } else if sender.tag == 2 {
            selectedCurrency = "Є"
        } else if sender.tag == 3 {
            selectedCurrency = "₽"
        }
        addAccountOutlet.isEnabled = true
        addAccountOutlet.alpha = 1
    }
 
    
}
