//
//  LimitViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 01.04.2022.
//

import UIKit

class LimitViewController: UIViewController {
    
    @IBOutlet weak var limitValueLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var dateDataView: UIView!
    
    let defaults = UserDefaults.standard
    var delegate: UpdateMainScreenViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateDataView.layer.cornerRadius = 10
        
        let limit = defaults.double(forKey: "Limit")
        let date = defaults.value(forKey: "Date") as! Date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        limitValueLabel.text = String(limit)
        dateValueLabel.text = "до:  \(dateFormatter.string(from: date))"

        deleteLimitButton.layer.cornerRadius = 10
        
        self.tabBarController?.tabBar.isHidden = true
    }
        
    @IBOutlet weak var deleteLimitButton: UIButton!
    @IBAction func deleteLimit(_ sender: UIButton) {
        addHaptic()
        defaults.setValue(nil, forKey: "Limit")
        defaults.setValue(nil, forKey: "Date")
        delegate?.update()
        dismiss(animated: true)
        
    }
    
}
