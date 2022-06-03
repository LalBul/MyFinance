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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var categoryTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var plusProgress: UIProgressView!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var minusProgress: UIProgressView!
    @IBOutlet weak var minusLabel: UILabel!
    
    let realm = try! Realm()
    var budget: Results<Budget>?
    var categoryArray: Results<Category>?
    var historyBudget: Results<HistoryBudget>?
    var arrayCategory: [Category]?
    
    var allHistorysSum: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addHaptic()
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sendActions(for: UIControl.Event.valueChanged)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for:.normal)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for:.selected)
        
        reportChartView.highlightPerTapEnabled = false
        reportChartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        
        plusProgress.transform = plusProgress.transform.scaledBy(x: 1, y: 2)
        minusProgress.transform = minusProgress.transform.scaledBy(x: 1, y: 2)
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.separatorStyle = .none
        
        historyBudget = realm.objects(HistoryBudget.self)
        
    }
 
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        categoryTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        if keyPath == "contentSize" {
            if let tbl = object as? UITableView {
                if tbl == self.categoryTableView {
                    if let newvalue = change?[.newKey] {
                        let newsize  = newvalue as! CGSize
                        self.categoryTableViewHeight.constant = newsize.height
                    }
                }
            }
        }
    }
    
    func updateData() {
        
        categoryArray = realm.objects(Category.self)
        var downloadDataEnty: [PieChartDataEntry] = []
        let colors: [UIColor] = [HexColor("2f9626")!, HexColor("962626")!]
        
        let newPieChartDataPlus = PieChartDataEntry()
        let newPieChartDataMinus = PieChartDataEntry()
        
        if let history = historyBudget {
            for i in history {
                if i.sum > 0 {
                    newPieChartDataPlus.value += i.sum
                } else if i.sum < 0 {
                    newPieChartDataMinus.value += i.sum * -1
                }
            }
        }

        if newPieChartDataPlus.value == 0 && newPieChartDataMinus.value == 0 {
            plusProgress.progress = 0
            minusProgress.progress = 0
        } else {
            plusProgress.progress = Float(newPieChartDataPlus.value / (newPieChartDataPlus.value + newPieChartDataMinus.value))
            minusProgress.progress = Float(newPieChartDataMinus.value / (newPieChartDataPlus.value + newPieChartDataMinus.value))
        }
        
        allHistorysSum = Double(newPieChartDataMinus.value)
        
        plusLabel.text = String(newPieChartDataPlus.value) + " ₽" + " — " + String(format: "%.2f", plusProgress.progress * 100) + " %"
        minusLabel.text = String(-newPieChartDataMinus.value) + " ₽" + " — " + String(format: "%.2f", minusProgress.progress * 100) + " %"
        
        newPieChartDataPlus.label = "Доходы"
        newPieChartDataMinus.label = "Расходы"
        
        downloadDataEnty = [newPieChartDataPlus, newPieChartDataMinus]
        
        reportChartView.drawEntryLabelsEnabled = false
        reportChartView.legend.textColor = .white
        reportChartView.holeColor = .clear
        reportChartView.transparentCircleColor = .clear
        
        let dataSet = PieChartDataSet(entries: downloadDataEnty, label: nil)
        dataSet.colors = colors
        dataSet.valueFont = .boldSystemFont(ofSize: 0)
        
        let data = PieChartData(dataSet: dataSet)
        reportChartView.data = data
        
        categoryTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        categoryTableView.reloadData()
    }
    
    @IBAction func sortedReport(_ sender: UISegmentedControl) {
        addHaptic()
        let dateFormatter = DateFormatter()
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            dateFormatter.dateFormat = "MM-yyyy"
            historyBudget = realm.objects(HistoryBudget.self).filter("dateMonth == %@", dateFormatter.string(from: Date())).sorted(byKeyPath: "date", ascending: false)
            updateData()
            break
        case 1:
            dateFormatter.dateFormat = "yyyy"
            historyBudget = realm.objects(HistoryBudget.self).filter("dateYear == %@", dateFormatter.string(from: Date())).sorted(byKeyPath: "date", ascending: false)
            updateData()
            break
        default:
            break
        }
        reportChartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        categoryTableView.reloadData()
    }
    
    
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == categoryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReportCategoryCell
            if let category = categoryArray?[indexPath.row] {
                let dateFormatter = DateFormatter()
                var categorySum: Double = category.items.sum(ofProperty: "amount")
                var categorySumForLabel: Double = 0
                if segmentedControl.selectedSegmentIndex == 0 {
                    dateFormatter.dateFormat = "MM-yyyy"
                    categorySum = category.items.filter("dateMonth == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amount")
                    if category.currency == "₽" {
                        categorySumForLabel = category.items.filter("dateMonth == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amount")
                    } else if category.currency == "Є" {
                        categorySumForLabel = category.items.filter("dateMonth == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amountInEU")
                    } else if category.currency == "$" {
                        categorySumForLabel = category.items.filter("dateMonth == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amountInUS")
                    }
                } else if segmentedControl.selectedSegmentIndex == 1 {
                    dateFormatter.dateFormat = "yyyy"
                    categorySum = category.items.filter("dateYear == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amount")
                    if category.currency == "₽" {
                        categorySumForLabel = category.items.filter("dateYear == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amount")
                    } else if category.currency == "Є" {
                        categorySumForLabel = category.items.filter("dateYear == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amountInEU")
                    } else if category.currency == "$" {
                        categorySumForLabel = category.items.filter("dateYear == %@ AND isBudget == true", dateFormatter.string(from: Date())).sum(ofProperty: "amountInUS")
                    }
                }
                cell.categoryName.text = category.title
                cell.sumCategory.text = String(categorySumForLabel) + " \(category.currency)"
                cell.progressView.progressTintColor = HexColor(category.color)
                cell.progressView.progress = Float(categorySum / allHistorysSum)
                if categorySum == 0 && allHistorysSum == 0 {
                    cell.progressView.progress = 0
                }
            }
            cell.selectionStyle = .none
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
}

