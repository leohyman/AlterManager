//
//  ActionSheetViewController.swift
//  SMHCommerce
//
//  Created by lvzhao on 2020/1/12.
//  Copyright © 2020年 lvzhao. All rights reserved.
//

import UIKit
import SnapKit
import PKHUD
import ReactiveCocoa

enum LZAlertType: Int {
    case sheet          //
    case sysAlert       // 系统弹框
    case sysSheet       // 系统弹框
}



class LZAlertViewController: UIViewController {
    
// MARK: - 外界调用的属性值
    var cancelBlock: cancelBlock?
    var sureBlock: sureBlock?

    var headTitle: String?
    var message: String?
    var dictionary: [String:AnyObject]?


    
// MARK:-内部属性
    typealias cancelBlock = (String)->Swift.Void
    typealias sureBlock = (String)->Swift.Void

    
    fileprivate var contentView = UIView()
    fileprivate var alertType : LZAlertType?
    fileprivate var contentHeight: CGFloat = 0


    
    required init?(alert:LZAlertType!, title: String!, message:String!,dictionary:[String:AnyObject]) {
        super.init(nibName: nil, bundle: nil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .custom
        
        self.dictionary = dictionary
        self.headTitle = title
        self.message = message
        
        self.alertType = alert
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch alertType {
        case .sheet:
            UIView.animate(withDuration: 0.25) {
                self.contentView.frame = CGRect(x: 0, y: kScreenHeight - self.contentHeight, width: kScreenWidth, height: self.contentHeight)
            }
     
        default: break
            
        }
        
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化UI
        setupUIViews()
    }
}

// MARK: 初始化UI
extension LZAlertViewController {
    func setupUIViews() {
    
        
        
        switch self.alertType {
        case .sheet:
            initSheetView()
        
        default:break
            
        }
    }
    
    
    func initSheetView() {
        
        let dataArray : [String] = self.dictionary!["dataArray"] as! Array;
        
        let rowHight: CGFloat = 55
        let footerViewLineHight: CGFloat = 10

        self.contentHeight = CGFloat((dataArray.count * Int(rowHight))) + footerViewLineHight
        if kisPhoneX(){
            self.contentHeight += 34;
        }
        
        contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: self.contentHeight)
        view.addSubview(contentView)
        contentView.backgroundColor = UIColor.white
        
        
        //for循环待索引
        for (index,item) in dataArray.enumerated() {
            let itemBtn = UIButton.init(type: .custom)
            contentView.addSubview(itemBtn)
            itemBtn.setTitleColor(UIColor.red, for: .normal)
            itemBtn.setTitle(item, for: .normal)
            
            let top = index * Int(rowHight)
            itemBtn.snp.makeConstraints { (make) in
                make.left.equalTo(0)
                make.width.equalTo(kScreenWidth)
                make.height.equalTo(rowHight)
                make.top.equalTo(top)
            }

            let lineView = UIView()
            lineView.backgroundColor = UIColorFromHex(rgbValue: 0xE5E5E5)
            //创建剑间隔线
            if(index == dataArray.count - 1){
                
                itemBtn.snp.updateConstraints{ (make) in
                    make.top.equalTo(top + Int(footerViewLineHight))
                }

               
                self.contentView.addSubview(lineView)
                lineView.snp.makeConstraints { (make) in
                    make.top.equalTo(top)
                    make.left.equalTo(0)
                    make.width.equalTo(kScreenWidth)
                    make.height.equalTo(10)
                }
            } else {
               
                itemBtn.addSubview(lineView)
                lineView.snp.makeConstraints { (make) in
                    make.top.equalTo(rowHight-0.5)
                    make.left.equalTo(0)
                    make.width.equalTo(kScreenWidth)
                    make.height.equalTo(0.5)
                }
            }
            
            itemBtn.reactive.controlEvents(.touchUpInside).observeResult { (button) in
                if(index == dataArray.count - 1){
                    self.sheetViewDismiss(animate: true)
                    return
                }
                if (self.sureBlock != nil) {
                    self.sureBlock!(String(index))
                }
                self.sheetViewDismiss(animate: true)
            }
        }
    }
    
    
    private func initAlertAction() {
       

    }
}



// MARK: 点击屏幕弹出退出
extension LZAlertViewController {
    
   private func sheetViewDismiss(animate:Bool) {

        UIView.animate(withDuration: 0.25, animations: {
            self.contentView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: self.contentHeight)
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sheetViewDismiss(animate: true)
    }
    
    @objc func cancelBtnDidClick(btn: UIButton) {
        sheetViewDismiss(animate: true)
    }
}



//MARK:-类方法
extension LZAlertViewController{
    
    class func systemAlter(_ alertType: LZAlertType, alterTitle title: String?, message: String?, cancel: String?, sure: String?, dictionary: [AnyHashable : Any]?, cancelBlock: @escaping (_ object: Any?) -> Void, sureBlock: @escaping (_ object: Any?) -> Void) {
        
        
        switch alertType {
        case .sysAlert:
            let alertController = UIAlertController.init(title: title, message:message, preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
                cancelBlock("0")
            }
            alertController.addAction(cancelAction)
            let sureAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
                sureBlock("1")
            }
            alertController.addAction(sureAction)
            currentVC()!.present(alertController, animated: false, completion:  nil)
        default:
            let alertController = UIAlertController.init(title: title, message:message, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
                cancelBlock("0")
            }
            alertController.addAction(cancelAction)

            let dataArray : [String] = dictionary!["dataArray"] as! [String]
            for item in dataArray {

            let itemAction = UIAlertAction.init(title: item, style: .default) { (action) in

            //查询
            let index = dataArray.firstIndex(of: item)
                sureBlock(index)
            }
            alertController.addAction(itemAction)
            }

            currentVC()!.present(alertController, animated: true, completion:  nil)
        }
    }
    
}

//屏幕的高
let kScreenHeight = UIScreen.main.bounds.height
//屏幕的款
let kScreenWidth = UIScreen.main.bounds.width

//是否是iphoneX
func kisPhoneX() -> Bool {
    if #available(iOS 11, *) {
          guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
              return false
          }
          
          if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
              print(unwrapedWindow.safeAreaInsets)
              return true
          }
    }
    return false
}

//十六进制颜色值
func UIColorFromHex(rgbValue:Int) -> (UIColor) {
    return UIColor.init(_colorLiteralRed:((Float)((rgbValue & 0xFF0000) >> 16))/255.0,
                                    green: ((Float)((rgbValue & 0xFF00) >> 8))/255.0,
                                    blue: ((Float)(rgbValue & 0xFF))/255.0 ,
                                    alpha: 1.0)
    
}



// 获取顶层控制器 根据window
func currentVC() -> (UIViewController?) {
    var window = UIApplication.shared.keyWindow
    //是否为当前显示的window
    if window?.windowLevel != UIWindow.Level.normal{
        let windows = UIApplication.shared.windows
        for  windowTemp in windows{
            if windowTemp.windowLevel == UIWindow.Level.normal{
                window = windowTemp
                break
            }
        }
    }
    let vc = window?.rootViewController
    return getTopVC(withCurrentVC: vc)
}
///根据控制器获取 顶层控制器
func getTopVC(withCurrentVC VC :UIViewController?) -> UIViewController? {
    if VC == nil {
        print("🌶： 找不到顶层控制器")
        return nil
    }
    if let presentVC = VC?.presentedViewController {
        //modal出来的 控制器
        return getTopVC(withCurrentVC: presentVC)
    } else if let tabVC = VC as? UITabBarController {
        // tabBar 的跟控制器
        if let selectVC = tabVC.selectedViewController {
            return getTopVC(withCurrentVC: selectVC)
        }
        return nil
    } else if let naiVC = VC as? UINavigationController {
        // 控制器是 nav
        return getTopVC(withCurrentVC:naiVC.visibleViewController)
    } else {
        // 返回顶控制器
        return VC
    }
}

func showLoading(view : UIView){
    HUD.show(.systemActivity, onView: view)
}

func showDelayedDismissTitle(title:String ,view:UIView){
    HUD.show(.label(title), onView: view)
}

func dismiss() {
    HUD.hide(animated: true)
}
