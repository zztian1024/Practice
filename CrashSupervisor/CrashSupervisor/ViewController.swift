//
//  ViewController.swift
//  CrashSupervisor
//
//  Created by Tian on 2020/9/19.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func touchAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            CrashMaker.outOfBounds()
        case 1:
            CrashMaker.signalCrash()
            break
        default:
            break
        }
    }
}

