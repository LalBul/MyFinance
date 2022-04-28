//
//  AddItemViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 30.03.2022.
//

import UIKit
import SwiftUI
import RealmSwift

protocol UpdateAccount {
    func updateAccount(account: Account)
    func updateBudget()
    func closedView()
}

class AddItemViewController: UIViewController, UpdateAccount {
    
    func updateBudget() {
        selectedAccount = nil
        myBudget = realm.objects(Budget.self)
        selectedAccountOrBudgetLabel.text = "Оплата с основного бюджета"
    }
    
    func closedView() {
        if selectedAccount == nil && myBudget == nil {
            switchAccount.isOn = false
        }
    }
    
    func updateAccount(account: Account) {
        myBudget = nil
        selectedAccount = account
        selectedAccountOrBudgetLabel.text = "Оплата со счёта: " + (selectedAccount?.title ?? "") + " " + (selectedAccount?.currency ?? "")
    }
    
    @IBOutlet weak var wasteTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var addItemOutlet: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var selectedAccountOrBudgetLabel: UILabel!
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    var defaultValue: Double = 0
    var selectedCategory: Category?
    var myBudget: Results<Budget>?
    var items = ItemsTableViewController()
    var selectedAccount: Account?
    weak var delegate: ItemsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wasteTextField.becomeFirstResponder()
        
        defaultValue = defaults.double(forKey: "Limit")
        
        wasteTextField.attributedPlaceholder = NSAttributedString(string: "Название покупки", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)])
        wasteTextField.layer.cornerRadius = 10
        
        categoryLabel.text = selectedCategory?.title
        
        amountTextField.attributedPlaceholder = NSAttributedString(string: "Сумма покупки \(selectedCategory?.currency ?? "")", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        amountTextField.layer.cornerRadius = 10
        amountTextField.keyboardType = .decimalPad
        amountTextField.delegate = self
        
        addItemOutlet.layer.cornerRadius = 10
        datePickerView.maximumDate = Date()
    }
    
    @IBOutlet weak var switchAccount: UISwitch!
    @IBAction func switchAccountOn(_ sender: UISwitch) {
        if sender.isOn == true {
            performSegue(withIdentifier: "goToAccounts", sender: self)
        } else if sender.isOn == false {
            myBudget = nil
            selectedAccount = nil
            selectedAccountOrBudgetLabel.text = "Оплата со счёта или бюджета: "
        }
    }
    
    @IBAction func addItem(_ sender: UIButton) {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = ","
        if let waste = wasteTextField.text, let amount = amountTextField.text {
            var format = numberFormatter.number(from: amount)
            if format == nil {
                numberFormatter.decimalSeparator = "."
                format = numberFormatter.number(from: amount)
                format = 0
            }
            guard let amountInDouble = format as? Double else {fatalError("Error converting in Double")}
            let newItem = Item()
            newItem.date = datePickerView.date
            if waste != "" {
                newItem.title = waste
            } else {
                newItem.title = "Новая покупка"
            }
            if amountInDouble > 0 {
                newItem.amount = amountInDouble
            } else {
                newItem.amount = 0
            }
            do {
                try realm.write {

                    if switchAccount.isOn {
                        if selectedAccount != nil {
                            let newAccountHistory = AccountHistory()
                            newAccountHistory.sum = -amountInDouble
                            if wasteTextField.text != "" {
                                newAccountHistory.operation = wasteTextField.text ?? "Трата"
                            } else {
                                newAccountHistory.operation = "Трата"
                            }
                            newAccountHistory.date = datePickerView.date
                            selectedAccount?.history.append(newAccountHistory)
                            selectedAccount?.collected -= amountInDouble
                        } else if myBudget != nil {
                                                    if selectedCategory?.currency == "$" {
                                                        myBudget?[0].collected -= amountInDouble * 80
                                                    } else if selectedCategory?.currency == "Є" {
                                                        myBudget?[0].collected -= amountInDouble * 90
                                                    } else if selectedCategory?.currency == "₽" {
                                                        myBudget?[0].collected -= amountInDouble
                                                    }
                                                    let newHistoryBudget = HistoryBudget()
                                                    newHistoryBudget.sum = -amountInDouble
                                                    newHistoryBudget.currency = selectedCategory?.currency ?? ""
                                                    newHistoryBudget.date = datePickerView.date
                                                    if wasteTextField.text != "" {
                                                        newHistoryBudget.operation = wasteTextField.text ?? "Трата"
                                                    } else {
                                                        newHistoryBudget.operation = "Трата"
                                                    }
                                                    newHistoryBudget.getDateDay()
                                                    newHistoryBudget.getDateMonth()
                                                    newHistoryBudget.getDateYear()
                                                    myBudget?[0].history.append(newHistoryBudget)
                        }
                    }
                    selectedCategory?.items.append(newItem)
                    if defaults.double(forKey: "Limit") > 0 || defaults.double(forKey: "Limit") < 0  {
                        if selectedCategory?.currency == "$" {
                            defaults.setValue(defaultValue-amountInDouble * 80, forKey: "Limit")
                        } else if selectedCategory?.currency == "Є" {
                            defaults.setValue(defaultValue-amountInDouble * 90, forKey: "Limit")
                        } else if selectedCategory?.currency == "₽" {
                            defaults.setValue(defaultValue-amountInDouble, forKey: "Limit")
                        }
                    }
                    backAnimate()
                    delegate?.update()
                    dismiss(animated: true)
                }
            } catch {
                print("Error save item")
            }
        }
    }
    
    func backAnimate() {
        navigationController?.navigationBar.isHidden = false
        wasteTextField.text = ""
        amountTextField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAccounts" {
            let destinationVC = segue.destination as! SelectAccountTableViewController
            destinationVC.selectedCategory = selectedCategory
            destinationVC.delegate = self
        }
    }
    
}

extension AddItemViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            if string == "," {
                    let countdots = textField.text!.components(separatedBy: ",").count - 1
                    if countdots == 0 {
                        return true
                    } else {
                        if countdots > 0 && string == "," {
                            return false
                        } else {
                            return true
                        }
                    }
                }
                return true
        }
        return true
    }
    
}
