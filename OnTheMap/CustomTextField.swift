//
//  CustomTextField.swift
//  OnTheMap
//
//  Created by Ada Ji on 11/18/15.
//  Copyright © 2015 Ada Ji. All rights reserved.
//

import UIKit

// MARK: - CustomTextField: UITextField

class CustomTextField: UITextField {
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        customedTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customedTextField()
    }
    
    func customedTextField() -> Void {
        // Set left padding
        leftView = UIView(frame: CGRectMake(0.0, 0.0, 13.0, 0.0))
        leftViewMode = .Always
        
        backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.65)
        let darkerColor = UIColor(red: 238/255.0, green:62/255.0, blue:10/255.0, alpha: 1.0)
        textColor = darkerColor
        tintColor = darkerColor
        font = UIFont.systemFontOfSize(17.0)
        attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(17)])
    }

}
