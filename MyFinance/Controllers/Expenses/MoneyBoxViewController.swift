//
//  MoneyBoxViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 19.11.2021.
//

import UIKit
import RealmSwift
import SwiftUI
import UPCarouselFlowLayout

class MoneyBoxViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var moneyBoxCollectionView: UICollectionView!
    
    var moneyBoxes: Results<MoneyBox>?
    let defaults = UserDefaults.standard
    
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHaptic()
        loadItems()
        
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: 359, height: 128)
        layout.scrollDirection = .horizontal;
        
        moneyBoxCollectionView.layer.cornerRadius = 10
        moneyBoxCollectionView.dataSource = self
        moneyBoxCollectionView.delegate = self
        moneyBoxCollectionView.collectionViewLayout = layout
        
        purpose.delegate = self
        
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    
        tabBarController?.tabBar.isHidden = true
    }
    
    func loadItems() {
        moneyBoxes = realm.objects(MoneyBox.self)
        moneyBoxCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    }

    private var tap = UITapGestureRecognizer()
    private var blurEffectView = UIVisualEffectView()
    
    @IBOutlet var addMoneyBoxView: UIView!
    @IBOutlet weak var viewCreateButton: UIView!
    @IBOutlet weak var nameMoneyBox: UITextField!
    @IBOutlet weak var purpose: UITextField!
    @IBOutlet weak var addMoneyBoxButton: UIBarButtonItem!
    @IBAction func addMoneyBox(_ sender: UIBarButtonItem) {
        
        addHaptic()
        
        viewCreateButton.layer.cornerRadius = 10
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapBack))
        tap.isEnabled = true
        tap.delegate = self
        
        addMoneyBoxView.center.y = view.center.x + 100
        addMoneyBoxView.center.x = view.center.x
        addMoneyBoxView.transform = CGAffineTransform(scaleX: 0.05, y: 0.1)
        addMoneyBoxView.layer.cornerRadius = 10
        
        nameMoneyBox.layer.cornerRadius = 10
        
        purpose.keyboardType = .decimalPad
        purpose.layer.cornerRadius = 10
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
        view.addSubview(addMoneyBoxView)
        blurEffectView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.2) {
            self.addMoneyBoxView.center.y = self.view.center.y
            self.addMoneyBoxView.transform = CGAffineTransform.identity
            self.addMoneyBoxView.alpha = 1
            self.addMoneyBoxButton.isEnabled = false
        }
        
        self.nameMoneyBox.becomeFirstResponder()
    }
    
    @objc func tapBack(recognizer: UITapGestureRecognizer){
        back()
    }
    
    func back() {
        addHaptic()
        blurEffectView.removeFromSuperview()
        tap.isEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.addMoneyBoxView.alpha = 0
            self.addMoneyBoxView.center.y = self.view.center.y + 300
            self.addMoneyBoxView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            self.addMoneyBoxButton.isEnabled = true
            
        } completion: { _ in
            self.addMoneyBoxView.removeFromSuperview()
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        back()
    }

    @IBAction func addMoneyBoxButton(_ sender: UIButton) {
        addHaptic()
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = ","
        if let amount = purpose.text {
            var format = numberFormatter.number(from: amount)
            if format == nil {
                numberFormatter.decimalSeparator = "."
                format = numberFormatter.number(from: amount)
                format = 0
            }
            guard let amountInDouble = format as? Double else {fatalError("Error converting in Double")}
            let moneyBox = MoneyBox()
            if nameMoneyBox.text == "" {
                moneyBox.title = "Новая копилка"
            } else {
                moneyBox.title = nameMoneyBox.text ?? "Новая копилка"
            }
            moneyBox.purpose = amountInDouble
            moneyBox.collected = 0
            do {
                try realm.write {
                    realm.add(moneyBox)
                    back()
                    moneyBoxCollectionView.reloadData()
                }
            } catch {
                print("Error added new MoneyBox")
            }
        }
    }

}

extension MoneyBoxViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let moneyBox = moneyBoxes?.count {
            if moneyBox > 0 {
                self.moneyBoxCollectionView.restore()
                return moneyBox
            } else {
                self.moneyBoxCollectionView.setEmptyMessage("Копилок пока нет")
                return 0
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
    
        if let configureCell = moneyBoxCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? MoneyBoxCell {
            if let moneyBox = moneyBoxes?[indexPath.row] {
                
                if moneyBox.selected == true {
                    configureCell.view.layer.borderWidth = 1
                    configureCell.view.layer.borderColor = UIColor.white.cgColor
                }
                
                configureCell.index = indexPath // Функционал удаления Копилки
                configureCell.delegate = self //
                
                configureCell.purpose.text = String(moneyBox.purpose)
                configureCell.name.text = moneyBox.title
                configureCell.collected.text = String(format:"%.2f", moneyBox.collected) + " (" + String(format:"%.2f", moneyBox.collected / moneyBox.purpose * 100) + " %)" 
                
                configureCell.layer.borderWidth = CGFloat(3)
                configureCell.layer.borderColor = view.backgroundColor?.cgColor
                configureCell.view.layer.cornerRadius = 10
                configureCell.view.layer.masksToBounds = true
              
                
            }
            cell = configureCell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addHaptic()
        
        if moneyBoxes?[indexPath.row] != nil {
            do {
                try realm.write({
                    for i in 0..<moneyBoxes!.count {
                        moneyBoxes![i].selected = false
                    }
                    moneyBoxes![indexPath.row].selected = true
                    moneyBoxCollectionView.reloadData()
                })
            } catch {
                print("error")
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension MoneyBoxViewController: DataCollectionProtocol {
    //Функционал удаления Копилки
    func deleteData(index: Int) {
        do {
            try realm.write {
                realm.delete((moneyBoxes?[index])!)
                moneyBoxCollectionView.reloadData()
            }
        } catch {
            print("Error delete money box")
        }
    }
    
}

extension MoneyBoxViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == purpose {
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
