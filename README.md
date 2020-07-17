# LZSheetVC
Swift仿照微信更换头像的弹框


使用方法
```
let sheetVC = LZSheetViewController(cellTitleList: ["拍照", "从相册选择"])!
sheetVC.valueBlock = { index in
   print(index)
}
sheetVC.titleString = "选择一张照片"
currentVC()!.present(sheetVC, animated: false, completion:  nil)false, completion:  nil)     
```
