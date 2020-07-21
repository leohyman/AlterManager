//
//  ViewController.swift
//  AlterManager
//
//  Created by lvzhao on 2020/7/21.
//  Copyright © 2020 吕VV. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor.red
        
            
        let dataArray = ["弹框1","弹框2","弹框三"]
        for (index,item) in dataArray.enumerated(){
            let itemBtn = UIButton.init(type: .custom)
            view.addSubview(itemBtn)
            itemBtn.frame = CGRect(x: 0, y: 100 + index * 55, width: 200, height: 50)
            itemBtn.setTitle(item, for: .normal)
            itemBtn.tag = 100 + index
            itemBtn.addTarget(self, action: #selector(alertClick), for: .touchUpInside)
        }
        
    
        
        
    }


    @objc func alertClick(btn: UIButton) {
        print(btn)
        let dataArray : [String] = ["相册","拍一张","取消"];

        switch btn.tag {
        case 100:
    
            let sheetVC = LZAlertViewController.init(alert: .sheet, title: "选择一张照片", message: "", dictionary: ["dataArray":dataArray as AnyObject])
               sheetVC!.sureBlock = { index in
                   print("选择了啥\(index)")
               }
            currentVC()!.present(sheetVC!, animated: false, completion:  nil)
            
            
        case 101:
            LZAlertViewController.systemAlter(.sysAlert, alterTitle: "123", message: "345", cancel: "取消", sure: "确认", dictionary: nil, cancelBlock: { (cancel) in
                       print(cancel!)
                       
                   }) { (sure) in
                       
                       print(sure!)
                   }
            
        default:
            
          
            LZAlertViewController.systemAlter(.sysSheet, alterTitle: "123", message: "345", cancel: "取消", sure: "确认", dictionary: ["dataArray":dataArray], cancelBlock: { (cancel) in
                        print(cancel!)
            }) { (sure) in
                        
                print(sure!)
            }
            
        }
        
        
    }
    
}

