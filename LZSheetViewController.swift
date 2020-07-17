//
//  ActionSheetViewController.swift
//  SMHCommerce
//
//  Created by lvzhao on 2020/1/12.
//  Copyright © 2020年 lvzhao. All rights reserved.
//

import UIKit

class LZSheetViewController: LZBaseViewController {
    
// MARK: - 外界调用的属性值
    var valueBlock: valueBlock?
    /// cell内容
    var cellTitleList = [String]()
    /// cell字体颜色
    var cellTitleColor = UIColor.green
    /// cell字体大小
    var cellTitleFont: CGFloat = 17
    /// 标题
    var titleString: String? = ""
    /// 标题字体大小
    var titleFont: CGFloat = 15
    
    
// MARK:-内部属性
    typealias valueBlock = (NSInteger)->Swift.Void
    fileprivate var tableView = UITableView()
    fileprivate var overVeiw = UIView()
    fileprivate let cellID = "cellID"
    fileprivate var tableViewHight: CGFloat {
        return CGFloat(cellTitleList.count) * rowHight + headerViewHight + footerViewHight
    }
    fileprivate let rowHight: CGFloat = 50
    fileprivate let headerViewHight: CGFloat = 50
    fileprivate var footerViewLineHight: CGFloat = 5
    fileprivate var footerViewHight: CGFloat {
        return headerViewHight + footerViewLineHight
    }
    
    required init?(cellTitleList: [String]!) {
        super.init(nibName: nil, bundle: nil)
        // 初始化
        self.cellTitleList = cellTitleList;
        
        view.backgroundColor = UIColor.clear
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .custom
        
        // 初始化UI
        setupUIViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25) {
            var frame = self.tableView.frame
            frame.origin.y = kScreenHeight-self.tableViewHight
            self.tableView.frame = frame
            self.overVeiw.alpha = 0.5
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

// MARK: 初始化UI
extension LZSheetViewController {
    func setupUIViews() {
        overVeiw =
            UIView(frame: CGRect(x: 0, y: 0, width:kScreenWidth, height: kScreenHeight))
        overVeiw.backgroundColor = UIColor.black
        overVeiw.alpha = 0.0
        view.addSubview(overVeiw)
        tableView = UITableView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: tableViewHight), style: .plain)
        overVeiw.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.isPagingEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(TitleCell.classForCoder(), forCellReuseIdentifier: cellID)
    }
}

// MARK: 点击屏幕弹出退出
extension LZSheetViewController {
    
    func sheetViewDismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            var frame = self.tableView.frame
            frame.origin.y = kScreenHeight
            self.tableView.frame = frame
            self.overVeiw.alpha = 0
            
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sheetViewDismiss()
    }
    
    @objc func cancelBtnDidClick(btn: UIButton) {
        sheetViewDismiss()
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension LZSheetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let titleCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TitleCell
        titleCell.modelObject = cellTitleList[indexPath.row] as AnyObject
        return titleCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (self.valueBlock != nil) {
            self.valueBlock!(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return headerViewHight + 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: headerViewHight))
        // 标题
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: headerViewHight))
        titleLabel.text = titleString
        titleLabel.font = UIFont.systemFont(ofSize: titleFont)
        titleLabel.textColor = UIColor.lightGray
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        // 线
        let lineView = UIView(frame: CGRect(x: 0, y: view.frame.size.height-1, width: kScreenWidth, height: 1))
        lineView.backgroundColor =   UIColor(red: 220/250.0, green: 220/250.0, blue: 220/250.0, alpha: 1.0)
        view.addSubview(lineView)
        return view
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: footerViewHight))
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: footerViewLineHight))
        lineView.backgroundColor = UIColor.lightGray
        footerView.addSubview(lineView)
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: footerViewLineHight, width: kScreenWidth, height: footerViewHight-footerViewLineHight)
        footerView.addSubview(btn)
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: titleFont)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(cancelBtnDidClick(btn:)), for: .touchUpInside)
        
        return footerView;
    }
}


class TitleCell: LZBaseTableViewCell {

    let titleLabel = UILabel()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         
         self.backgroundColor = UIColor.white
         titleLabel.textAlignment = .center
         addSubview(titleLabel)
     }
     var modelObject : AnyObject?{
          didSet{
              
            titleLabel.textAlignment = .center;
            titleLabel.text = modelObject as! String?
          }
          
      }
    
    
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = self.bounds
    }

}
