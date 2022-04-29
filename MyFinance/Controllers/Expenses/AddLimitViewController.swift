//
//  LimitViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 07.05.2021.
//

import UIKit
import ChameleonFramework

class AddLimitViewController: UIViewController {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var buttonsNumebrsCollectionView: UICollectionView!

    @IBOutlet weak var numberBackgroundView: UIView!
    @IBOutlet weak var mainDatePicker: UIDatePicker!
    
    private var pointBool = true
    let defaults = UserDefaults.standard
    fileprivate let cellId = "cellId"
    
    let numbers = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "C"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        buttonsNumebrsCollectionView.delegate = self
        buttonsNumebrsCollectionView.dataSource = self
        buttonsNumebrsCollectionView.backgroundColor = .clear
        buttonsNumebrsCollectionView.register(KeyCell.self, forCellWithReuseIdentifier: cellId)
        buttonsNumebrsCollectionView.isScrollEnabled = false
        
        numberLabel.layer.masksToBounds = true
        numberLabel.layer.cornerRadius = 10
        numberLabel.layer.borderWidth = 2
        numberLabel.layer.borderColor = HexColor("1D2E42")?.cgColor
        
        numberBackgroundView.layer.cornerRadius = 10
    
        mainDatePicker.minimumDate = Date()
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

extension AddLimitViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
            numberLabel.text = "0"
            pointBool = true
        } else if numberLabel.text == "0" {
                if getNumber == "." {
                    numberLabel.text?.append(getNumber)
                    pointBool = false
                } else {
                    numberLabel.text = getNumber
                }
            } else if getNumber == "." {
                if pointBool == true {
                    numberLabel.text?.append(getNumber)
                    pointBool = false
                } else {return}
            } else {
                numberLabel.text?.append(getNumber)
            }
    }
    
}
