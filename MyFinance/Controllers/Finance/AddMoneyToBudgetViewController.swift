//
//  AddMoneyToBudgetViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 07.04.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework


class AddMoneyToBudgetViewController: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var nameIncome: UITextField!
    
    private var pointBool = true
    var realm = try! Realm()
    var budget: Results<Budget>?
    weak var delegate: MainFinanceViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in buttons {
            i.layer.cornerRadius = i.frame.size.height / 2
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
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
    
    func loadItems() {
        budget = realm.objects(Budget.self)
    }
    
    @IBAction func deleteSymbolButton(_ sender: UIButton) {
        addHaptic()
        deleteLastSymbolLabel()
        
    }
    
    @IBAction func addMoneyToBudget(_ sender: UIButton) {
        addHaptic()
        let newHistoryBudget = HistoryBudget()
        if sumLabel.text != "0" && sumLabel.text != "" {
            newHistoryBudget.sum = Double(sumLabel.text!)!
            if nameIncome.text != "" {
                newHistoryBudget.operation = nameIncome.text ?? ""
            } else {
                newHistoryBudget.operation = "Доход"
            }
            newHistoryBudget.date = Date()
            newHistoryBudget.currency = "₽"
            newHistoryBudget.getDateDay()
            newHistoryBudget.getDateMonth()
            newHistoryBudget.getDateYear()
            do {
                try realm.write({
                    budget?[0].collected += Double(sumLabel.text!)!
                    budget?[0].history.append(newHistoryBudget)
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


