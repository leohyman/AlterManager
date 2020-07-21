# AlterManager

##Swift仿照微信更换头像的弹框

###每次做项目，都有弹框的出现，习惯把所有弹框写到一块，这样即可管理，使用方便

使用方法
```
  let dataArray : [String] = ["相册","拍一张","取消"];
  let sheetVC = LZAlertViewController.init(alert: .sheet, title: "选择一张照片", message: "", dictionary: ["dataArray":dataArray as AnyObject])

  sheetVC!.sureBlock = { index in
  print("选择了啥\(index)")
  }
  currentVC()!.present(sheetVC!, animated: false, completion:  nil) 
  //更换alertType
  LZAlertViewController.systemAlter(.sysSheet, alterTitle: "123", message: "345", cancel: "取消", sure: "确认", dictionary: ["dataArray":dataArray], cancelBlock: { (cancel) in
  print(cancel!)
  }) { (sure) in

  print(sure!)
  }
  ```
### 里面用其他函数
  获取最上面的VC
  ```
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
```
###判断机型.宏. 颜色
```
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

 ```  
            
