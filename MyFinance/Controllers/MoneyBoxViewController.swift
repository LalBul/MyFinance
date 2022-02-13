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
        
        loadItems()
        
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
    
    var realm = try! Realm()
    
    var delegate: MoneyBoxDelegate?
    
    private var tap = UITapGestureRecognizer()
    private var blurEffectView = UIVisualEffectView()
    
    @IBOutlet var addMoneyBoxView: UIView!
    @IBOutlet weak var nameMoneyBox: UITextField!
    @IBOutlet weak var purpose: UITextField!
    @IBAction func addMoneyBox(_ sender: UIBarButtonItem) {
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapBack))
        tap.isEnabled = true
        tap.delegate = self
        
        addMoneyBoxView.layer.cornerRadius = 15
        addMoneyBoxView.center = view.center
        addMoneyBoxView.center.y -= 500
        addMoneyBoxView.center.x += 150
        addMoneyBoxView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
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
        }
        
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
        } completion: { _ in
            self.addMoneyBoxView.removeFromSuperview()
        }
    }
    
    @IBAction func addMoneyBoxButton(_ sender: UIButton) {
        let moneyBox = MoneyBox()
        moneyBox.title = nameMoneyBox.text ?? ""
        moneyBox.purpose = Double(purpose.text!)!
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

extension MoneyBoxViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moneyBoxes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let configureCell = moneyBoxCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? MoneyBoxCell {
            if let moneyBox = moneyBoxes?[indexPath.row] {
                
                configureCell.purpose.text = String(moneyBox.purpose)
                configureCell.name.text = moneyBox.title
                configureCell.collected.text = String(moneyBox.collected)
                
                configureCell.layer.borderWidth = CGFloat(3)
                configureCell.layer.borderColor = view.backgroundColor?.cgColor
                configureCell.view.layer.cornerRadius = 15
                configureCell.view.layer.masksToBounds = true
            }
            cell = configureCell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.getMainMoneyBox(moneyBox: (moneyBoxes?[indexPath.row])!)
        navigationController?.popToRootViewController(animated: true)
        
    }
    
}
