//
//  LimitViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 07.05.2021.
//

import UIKit

class AddLimitViewController: UIViewController {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var numberBackgroundView: UIView!
    @IBOutlet weak var mainDatePicker: UIDatePicker!
    
    private var pointBool = true
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in buttons {
            i.layer.cornerRadius = i.frame.size.height / 2
        }
        
        numberBackgroundView.layer.cornerRadius = 10
        
        mainDatePicker.minimumDate = Date()
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //Логика ввода точки, позволяет поставить её только один раз
    @IBAction func buttons(_ sender: UIButton) {
        addHaptic()
        if let senderButton = sender.currentTitle {
            if numberLabel.text == "0" {
                if senderButton == "." {
                    numberLabel.text?.append(senderButton)
                    pointBool = false
                } else {
                    numberLabel.text = senderButton
                }
            } else if sender.currentTitle == "." {
                if pointBool == true {
                    numberLabel.text?.append(senderButton)
                    pointBool = false
                } else {return}
            } else {
                numberLabel.text?.append(senderButton)
            }
        }
        
    }
    
    @IBAction func deleteSymbolButton(_ sender: UIButton) {
        addHaptic()
        deleteLastSymbolLabel()
       
    }
    
    @IBAction func addLimit(_ sender: UIButton) {
        addHaptic()
        if let number = numberLabel.text {
            if numberLabel.text != "0" && numberLabel.text != "" {
                guard let limit = Double(number) else {fatalError("Error converting in Double")}
                defaults.setValue(limit, forKey: "Limit")
                defaults.setValue(mainDatePicker.date, forKey: "Date")
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func swipeRightDeleteAmount(_ sender: UISwipeGestureRecognizer) {
        deleteLastSymbolLabel()
    }
    
    @IBAction func swipeLeftDeleteAmount(_ sender: UISwipeGestureRecognizer) {
        deleteLastSymbolLabel()
    }
    
    // Проверяет последний символ ли точка, если да, то точка удаляется и появляется возможность поставить её еще раз.
    func deleteLastSymbolLabel() {
        if numberLabel.text != "" {
            if let lastSymbol = numberLabel.text?.last {
                if lastSymbol == "." {
                    pointBool = true
                }
            }
            numberLabel.text?.removeLast()
        } else if numberLabel.text == "" {
            numberLabel.text = "0"
        }
    }
    
}
