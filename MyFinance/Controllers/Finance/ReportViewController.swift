//
//  ReportViewController.swift
//  MyFinance
//
//  Created by Вова Сербин on 22.04.2022.
//

import UIKit
import RealmSwift
import Charts
import ChameleonFramework
import MultiProgressView

class ReportViewController: UIViewController {
    
    @IBOutlet weak var reportChartView: PieChartView!

    
    let realm = try! Realm()
    var budget: Results<Budget>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateChartData()
        
        reportChartView.highlightPerTapEnabled = false
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChartData()
        
    }
    
    func updateChartData() {
        
        budget = realm.objects(Budget.self)
      
        var downloadDataEnty: [PieChartDataEntry] = []
        let colors: [UIColor] = [HexColor("24722E")!, HexColor("742524")!]
        
        let newPieChartDataPlus = PieChartDataEntry()
        let newPieChartDataMinus = PieChartDataEntry()
        
        if let history = budget?[0].history {
            for i in history {
                if i.sum > 0 {
                    if i.currency == "$" {
                        newPieChartDataPlus.value += i.sum * 80
                    
                    } else if i.currency == "Є" {
                        newPieChartDataPlus.value += i.sum * 90
                       
                    } else if i.currency == "₽" {
                        newPieChartDataPlus.value += i.sum
                       
                    }
                } else if i.sum < 0 {
                    if i.currency == "$" {
                        newPieChartDataMinus.value += i.sum * 80 * -1
                       
                    } else if i.currency == "Є" {
                        newPieChartDataMinus.value += i.sum * 90 * -1
                       
                    } else if i.currency == "₽" {
                        newPieChartDataMinus.value += i.sum * -1
                       
                    }
                }
            }
            
        }
   
        downloadDataEnty.append(newPieChartDataPlus)
        downloadDataEnty.append(newPieChartDataMinus)

        reportChartView.holeColor = .clear
        reportChartView.transparentCircleColor = .clear
        
        let dataSet = PieChartDataSet(entries: downloadDataEnty, label: nil)
        dataSet.colors = colors
        dataSet.valueFont = .boldSystemFont(ofSize: 0)
        
        let data = PieChartData(dataSet: dataSet)
        reportChartView.data = data
        
        
        
    }
   
}


