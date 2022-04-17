//
//  AddMoneyToAccountViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 17.04.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class AddMoneyToAccountViewController: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var nameIncome: UITextField!
    
    private var pointBool = true
    var realm = try! Realm()
    weak var delegate: AccountViewController?
    var selectedAccount: Account?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in buttons {
            i.layer.cornerRadius = i.frame.size.height / 2
        }

    }
    
    @IBAction func buttons(_ sender: UIButton) {
        addHaptic()
        if let senderButton = sender.currentTitle {
            if sumLabel.text == "0" {
                if senderButton == "." {
                    sumLabel.text?.append(senderButton)
                    pointBool = false
                } else {
                    sumLabel.text = senderButton
                }
            } else if sender.currentTitle == "." {
                if pointBool == true {
                    sumLabel.text?.append(senderButton)
                    pointBool = false
                } else {return}
            } else {
                sumLabel.text?.append(senderButton)
            }
        }
        
        
    }
    
    @IBAction func deleteSymbolButton(_ sender: UIButton) {
        addHaptic()
        deleteLastSymbolLabel()
        
    }
    
    @IBAction func addMoneyToBudget(_ sender: UIButton) {
        addHaptic()
        
        if let sumString = sumLabel.text {
            let sum = Double(sumString)!
            do {
                try realm.write({
                    let history = AccountHistory()
                    history.sum = sum
                    history.date = Date()
                    if nameIncome.text != "" {
                        history.operation = nameIncome.text ?? "Доход"
                    } else {
                        history.operation = "Доход"
                    }
                    selectedAccount?.history.append(history)
                    selectedAccount?.collected += sum
                    delegate?.update()
                    dismiss(animated: true)
                })
            } catch {
                print(error)
            }
        }
  
    }

    func deleteLastSymbolLabel() {
        addHaptic()
        if sumLabel.text != "" {
            if let lastSymbol = sumLabel.text?.last {
                if lastSymbol == "." {
                    pointBool = true
                }
            }
            sumLabel.text?.removeLast()
        } else if sumLabel.text == "" {
            sumLabel.text = "0"
        }
    }

}
