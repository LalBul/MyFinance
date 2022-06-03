//
//  ChangeCategoryViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 21.04.2022.
//

import UIKit
import ChameleonFramework
import RealmSwift

class ChangeCategoryViewController: UIViewController, UIColorPickerViewControllerDelegate {
    
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var categoryColorView: UIView!
    
    var selectedCategory: Category?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let category = selectedCategory {
            
            categoryNameTextField.text = category.title
            
            categoryColorView.backgroundColor = HexColor(category.color)
            categoryColorView.layer.cornerRadius = categoryColorView.frame.size.width/2
        }

        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        gesture.numberOfTapsRequired = 1
        viewColor.addGestureRecognizer(gesture)
        
        tabBarController?.tabBar.isHidden = true

    }
    
    @objc func viewTapped() {
        if #available(iOS 14.0, *) {
            addHaptic()
            let colorPickerVC = UIColorPickerViewController()
            colorPickerVC.delegate = self
            present(colorPickerVC, animated: true)
        }
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        let color = viewController.selectedColor
        categoryColorView.backgroundColor = color
    }
    
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        categoryColorView.backgroundColor = color
    }

    @IBAction func changeCategory(_ sender: UIButton) {
        addHaptic()
        
        navigationController?.popViewController(animated: true)
        
        do {
            try realm.write({
                selectedCategory?.title = categoryNameTextField.text ?? "Категория"
                selectedCategory?.color = categoryColorView.backgroundColor?.hexValue() ?? "000000"
            })
        } catch {
            print(error)
        }
        
    }
    

}
