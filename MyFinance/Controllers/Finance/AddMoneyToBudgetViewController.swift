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
    
    
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var nameIncome: UITextField!
    @IBOutlet weak var buttonsNumebrsCollectionView: UICollectionView!
    
    private var pointBool = true
    var realm = try! Realm()
    var budget: Results<Budget>?
    weak var delegate: MainFinanceViewController?
    
    fileprivate let cellId = "cellId"
    let numbers = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "C"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHaptic()
        
        buttonsNumebrsCollectionView.delegate = self
        buttonsNumebrsCollectionView.dataSource = self
        buttonsNumebrsCollectionView.backgroundColor = .clear
        buttonsNumebrsCollectionView.register(KeyCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    }
    
    func loadItems() {
        budget = realm.objects(Budget.self)
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

extension AddMoneyToBudgetViewController:  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! KeyCell
        cell.digitsLabel.text = numbers[indexPath.item]
        cell.digitsLabel.tintColor = .white
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
        
        return .init(top: 30, left: leftRightPadding, bottom: 0, right: leftRightPadding)
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



