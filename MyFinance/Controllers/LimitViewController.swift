//
//  LimitViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 07.05.2021.
//

import UIKit

class LimitViewController: UIViewController {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    private var pointBool = true
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in buttons {
            i.layer.cornerRadius = i.frame.size.height / 2
        }
    }
    
    //Логика ввода точки, позволяет поставить её только один раз
    @IBAction func buttons(_ sender: UIButton) {
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
        print(pointBool)
    }
    
    @IBAction func addLimit(_ sender: UIButton) {
        if let number = numberLabel.text {
            guard let limit = Double(number) else {fatalError("Error converting in Double")}
            defaults.setValue(limit, forKey: "Limit")
            defaults.setValue(Date(), forKey: "Date")
            navigationController?.popToRootViewController(animated: true)
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
        }
        
        
    }
    
}
