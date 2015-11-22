//
//  StudentInformationCell.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/23/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

// MARK: - StudentInformationCell: UITableViewCell

class StudentInformationCell: UITableViewCell {
    
    // MARK: Color Constants
    
    static let green = UIColor(red: 25/255.0, green: 155/255.0, blue: 31/255.0, alpha: 1.0)
    static let orange = UIColor(red: 229/255.0, green: 119/255.0, blue: 75/255.0, alpha: 1.0)
    static let yellow = UIColor(red: 210/255.0, green: 191/255.0, blue: 53/255.0, alpha: 1.0)
    static let blue = UIColor(red: 93/255.0, green: 188/255.0, blue: 210/255.0, alpha: 1.0)
    static let gold = UIColor(red: 247/255.0, green: 159/255.0, blue: 23/255.0, alpha: 1.0)
    static let red = UIColor(red: 218/255.0, green: 85/255.0, blue: 42/255.0, alpha: 1.0)
    static let magenta = UIColor(red: 208/255.0, green: 67/255.0, blue: 172/255.0, alpha: 1.0)
    static let purple = UIColor(red: 143/255.0, green: 107/255.0, blue: 194/255.0, alpha: 1.0)

    // MARK: Properties
    
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    let colors = [green, orange, yellow, blue, gold, red, magenta, purple]
    
    // MARK: Configuration
    
    func configureCell(initials: String, name: String, location: String, urlString: String) {
        initialsLabel.layer.masksToBounds = true
        initialsLabel.layer.cornerRadius = initialsLabel.frame.size.width/2
        initialsLabel.backgroundColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        
        initialsLabel.text = initials
        nameLabel.text = name
        locationLabel.text = location
        urlLabel.text = urlString
    }
    
    // Prevent initials label to change background color when cell is highlighted
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = initialsLabel.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        initialsLabel.backgroundColor = color
    }
    
    // Prevent initials label to change background color when cell is selected
    override func setSelected(selected: Bool, animated: Bool) {
        let color = initialsLabel.backgroundColor
        super.setSelected(highlighted, animated: animated)
        initialsLabel.backgroundColor = color
    }

}










