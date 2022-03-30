//
//  MoneyBoxViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 19.11.2021.
//

import UIKit
import RealmSwift
import SwiftUI

class MoneyBoxViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var moneyBoxCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        moneyBoxCollectionView.layer.cornerRadius = 15
        moneyBoxCollectionView.dataSource = self
        moneyBoxCollectionView.delegate = self
        
        navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        purpose.delegate = self
        
        loadItems()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func loadItems() {
        moneyBoxes = realm.objects(MoneyBox.self)
        moneyBoxCollectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems()
    }

    var moneyBoxes: Results<MoneyBox>?
    let defaults = UserDefaults.standard
    
    var realm = try! Realm()
    
    private var tap = UITapGestureRecognizer()
    private var blurEffectView = UIVisualEffectView()
    
    @IBOutlet var addMoneyBoxView: UIView!
    @IBOutlet weak var nameMoneyBox: UITextField!
    @IBOutlet weak var purpose: UITextField!
    @IBOutlet weak var addMoneyBoxButton: UIBarButtonItem!
    @IBAction func addMoneyBox(_ sender: UIBarButtonItem) {
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapBack))
        tap.isEnabled = true
        tap.delegate = self
        
        addMoneyBoxView.layer.cornerRadius = 15
        addMoneyBoxView.center = view.center
        addMoneyBoxView.center.y -= 500
        addMoneyBoxView.center.x += 150
        addMoneyBoxView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        nameMoneyBox.layer.cornerRadius = 15
        
        purpose.keyboardType = .decimalPad
        purpose.layer.cornerRadius = 20
        
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView)
        view.addSubview(addMoneyBoxView)
        blurEffectView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.25) {
            self.addMoneyBoxView.center.y += 500
            self.addMoneyBoxView.center.x = self.view.center.x
            self.addMoneyBoxView.transform = CGAffineTransform.identity
            self.addMoneyBoxButton.isEnabled = false
        }
        
        self.nameMoneyBox.becomeFirstResponder()
        
    }
    
    @objc func tapBack(recognizer: UITapGestureRecognizer){
        back()
    }
    
    func back() {
        blurEffectView.removeFromSuperview()
        tap.isEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.addMoneyBoxView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.addMoneyBoxView.center.y += 500
            self.addMoneyBoxButton.isEnabled = true
        } completion: { _ in
            self.addMoneyBoxView.removeFromSuperview()
        }
    }
    
    @IBAction func addMoneyBoxButton(_ sender: UIButton) {
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
                moneyBox.title = "New Money Box"
            } else {
                moneyBox.title = nameMoneyBox.text ?? "New Money Box"
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
        return moneyBoxes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
    
        if let configureCell = moneyBoxCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? MoneyBoxCell {
            if let moneyBox = moneyBoxes?[indexPath.row] {
                
                configureCell.index = indexPath // Функционал удаления Копилки
                configureCell.delegate = self //
                
                configureCell.purpose.text = String(moneyBox.purpose)
                configureCell.name.text = moneyBox.title
                configureCell.collected.text = String(moneyBox.collected)
                
                configureCell.layer.borderWidth = CGFloat(3)
                configureCell.layer.borderColor = view.backgroundColor?.cgColor
                configureCell.view.layer.cornerRadius = 15
                configureCell.view.layer.masksToBounds = true
              
                configureCell.view.addGestureRecognizer(longPressRecognizer)
                
            }
            cell = configureCell
        }
        return cell
    }

    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // ------- Haptic вибрация
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.selectionChanged()
        // -------
        if moneyBoxes?[indexPath.row] != nil {
            do {
                try realm.write({
                    for i in 0..<moneyBoxes!.count {
                        moneyBoxes![i].selected = false
                    }
                    moneyBoxes![indexPath.row].selected = true
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
            let allowedCharacters = CharacterSet(charactersIn:",0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    
    
}
