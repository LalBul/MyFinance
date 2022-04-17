//
//  AddItemViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 30.03.2022.
//

import UIKit
import SwiftUI
import RealmSwift

class AddItemViewController: UIViewController {
    
    @IBOutlet weak var wasteTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var addItemOutlet: UIButton!
    @IBOutlet weak var switchBudget: UISwitch!

    let realm = try! Realm()
    let defaults = UserDefaults.standard
    var defaultValue: Double = 0
    var selectedCategory: Category?
    var myBudget: Results<Budget>?
    var items = ItemsTableViewController()
    weak var delegate: ItemsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wasteTextField.becomeFirstResponder()
        
        defaultValue = defaults.double(forKey: "Limit")
        
        wasteTextField.attributedPlaceholder = NSAttributedString(string: "Название покупки", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30)])
        wasteTextField.layer.cornerRadius = 10
        
        amountTextField.attributedPlaceholder = NSAttributedString(string: "Сумма покупки", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        amountTextField.layer.cornerRadius = 10
        amountTextField.keyboardType = .decimalPad
        
        addItemOutlet.layer.cornerRadius = 10
        datePickerView.maximumDate = Date()
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
                    if switchBudget.isOn {
                        myBudget = realm.objects(Budget.self)
                        myBudget?[0].collected -= amountInDouble
                        let newHistoryBudget = HistoryBudget()
                        newHistoryBudget.sum = -amountInDouble
                        newHistoryBudget.date = datePickerView.date
                        if wasteTextField.text != "" {
                            newHistoryBudget.operation = wasteTextField.text ?? "Трата"
                        } 
                        newHistoryBudget.getDateDay()
                        newHistoryBudget.getDateMonth()
                        newHistoryBudget.getDateYear()
                        realm.add(newHistoryBudget)
                    }
                    selectedCategory?.items.append(newItem)
                    if defaults.double(forKey: "Limit") > 0  {
                        defaults.setValue(defaultValue-amountInDouble, forKey: "Limit")
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
    
}


extension AddItemViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            let allowedCharacters = CharacterSet(charactersIn:",0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
}
