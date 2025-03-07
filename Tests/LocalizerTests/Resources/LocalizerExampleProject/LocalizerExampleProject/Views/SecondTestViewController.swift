//
//  SecondTestViewController.swift
//  LocalizerExampleProject
//
//  Created by Manuel Rodriguez Sebastian on 21/2/23.
//

import UIKit

class SecondTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let test1 = "test1".localized()
        let test2 = NSLocalizedString("test2", comment: "").uppercased()
        
        let number = 0
        var test3: String
        if number == 0 {
            test3 = NSLocalizedString("test3", comment: "")
        } else {
            test3 = ""
        }
        
        var test4 = "test4".localized()
        
        let test4 = "hey_text".localized()
        let test5 = "bye_text".localized()
    }
}

