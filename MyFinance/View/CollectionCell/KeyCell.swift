//
//  KeyCell.swift
//  MyFinance
//
//  Created by Вова Сербин on 28.04.2022.
//

import UIKit

class KeyCell: UICollectionViewCell {
    
    let digitsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        digitsLabel.text = "8"
        digitsLabel.textAlignment = .center
        digitsLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        digitsLabel.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [digitsLabel])
        stackView.axis = .vertical
        
        addSubview(stackView)
        stackView.centerInSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
