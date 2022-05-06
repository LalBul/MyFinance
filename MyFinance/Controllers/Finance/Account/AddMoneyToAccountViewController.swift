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
    
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var nameIncome: UITextField!
    @IBOutlet weak var buttonsNumebrsCollectionView: UICollectionView!
    
    private var pointBool = true
    var realm = try! Realm()
    weak var delegate: AccountViewController?
    var selectedAccount: Account?
    
    fileprivate let cellId = "cellId"
    let numbers = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "C"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsNumebrsCollectionView.delegate = self
        buttonsNumebrsCollectionView.dataSource = self
        buttonsNumebrsCollectionView.backgroundColor = .clear
        buttonsNumebrsCollectionView.register(KeyCell.self, forCellWithReuseIdentifier: cellId)
        buttonsNumebrsCollectionView.isScrollEnabled = false
    }
    
    // Проверяет последний символ ли точка, если да, то точка удаляется и появляется возможность поставить её еще раз.
    func deleteLastSymbolLabel() {
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
    
}

extension AddMoneyToAccountViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! KeyCell
        cell.digitsLabel.text = numbers[indexPath.item]
        cell.backgroundColor = HexColor("19365D")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let leftRightPadding = view.frame.width * 0.13
        let interSpacing = view.frame.width * 0.1
        
        let cellWidth = (view.frame.width - 2 * leftRightPadding - 2 * interSpacing) / 3
        
        return .init(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        // some basic math/geometry
        
        let leftRightPadding = view.frame.width * 0.1
        
        return .init(top: 16, left: leftRightPadding, bottom: 16, right: leftRightPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addHaptic()
        
        //Логика ввода точки, позволяет поставить её только один раз
        
        let getNumber = numbers[indexPath.row]
        
        if indexPath.row == 11 {
            sumLabel.text = "0"
            pointBool = true
        } else if sumLabel.text == "0" {
            if getNumber == "." {
                sumLabel.text?.append(getNumber)
                pointBool = false
            } else {
                sumLabel.text = getNumber
            }
        } else if getNumber == "." {
            if pointBool == true {
                sumLabel.text?.append(getNumber)
                pointBool = false
            } else {return}
        } else {
            sumLabel.text?.append(getNumber)
        }
    }
}
