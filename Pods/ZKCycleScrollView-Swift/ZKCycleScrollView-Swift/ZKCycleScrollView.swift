//
//  ZKCycleScrollView.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/8.
//  Copyright © 2019 bestdew. All rights reserved.
//
//                      d*##$.
// zP"""""$e.           $"    $o
//4$       '$          $"      $
//'$        '$        J$       $F
// 'b        $k       $>       $
//  $k        $r     J$       d$
//  '$         $     $"       $~
//   '$        "$   '$E       $
//    $         $L   $"      $F ...
//     $.       4B   $      $$$*"""*b
//     '$        $.  $$     $$      $F
//      "$       R$  $F     $"      $
//       $k      ?$ u*     dF      .$
//       ^$.      $$"     z$      u$$$$e
//        #$b             $E.dW@e$"    ?$
//         #$           .o$$# d$$$$c    ?F
//          $      .d$$#" . zo$>   #$r .uF
//          $L .u$*"      $&$$$k   .$$d$$F
//           $$"            ""^"$$$P"$P9$
//          JP              .o$$$$u:$P $$
//          $          ..ue$"      ""  $"
//         d$          $F              $
//         $$     ....udE             4B
//          #$    """"` $r            @$
//           ^$L        '$            $F
//             RN        4N           $
//              *$b                  d$
//               $$k                 $F
//               $$b                $F
//                 $""               $F
//                 '$                $
//                  $L               $
//                  '$               $
//                   $               $

import UIKit

public typealias ZKCycleScrollViewCell = UICollectionViewCell

public enum ZKScrollDirection: Int {
    case horizontal
    case vertical
}

@objc public protocol ZKCycleScrollViewDataSource: NSObjectProtocol {
    /// Return number of pages
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int
    /// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndex:
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt index: Int) -> ZKCycleScrollViewCell
}

@objc public protocol ZKCycleScrollViewDelegate: NSObjectProtocol {
    /// Called when the cell is clicked
    @objc optional func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt index: Int)
    /// Called when the offset changes. The progress range is from 0 to the maximum index value, which means the progress value for a round of scrolling
    @objc optional func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView, progress: Double)
    /// Called when scrolling to a new index page
    @objc optional func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didScrollFromIndex fromIndex: Int, toIndex: Int)
}

@IBDesignable open class ZKCycleScrollView: UIView {
    
    @IBOutlet open weak var delegate: ZKCycleScrollViewDelegate?
    @IBOutlet open weak var dataSource: ZKCycleScrollViewDataSource?
    
    #if TARGET_INTERFACE_BUILDER
    @IBInspectable open var scrollDirection: Int = 0
    #else
    /// default horizontal. scroll direction
    open var scrollDirection: ZKScrollDirection = .horizontal {
        didSet {
            switch scrollDirection {
            case .vertical:
                flowLayout?.scrollDirection = .vertical
            default:
                flowLayout?.scrollDirection = .horizontal
            }
        }
    }
    #endif
    /// default 3.f. automatic scroll time interval
    @IBInspectable open var autoScrollInterval: TimeInterval = 3 {
        didSet {
            addTimer()
        }
    }
    @IBInspectable open var isAutoScroll: Bool = true {
        didSet {
            addTimer()
        }
    }
    /// default true. turn off any dragging temporarily
    @IBInspectable open var allowsDragging: Bool = true {
        didSet {
            collectionView.isScrollEnabled = allowsDragging
        }
    }
     /// default the view size
    @IBInspectable open var itemSize: CGSize = CGSize.zero {
        didSet {
            itemSizeFlag = true
            flowLayout.itemSize = itemSize
            flowLayout.headerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
            flowLayout.footerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
        }
    }
    /// default 0.0
    @IBInspectable open var itemSpacing: CGFloat = 0.0 {
        didSet {
            flowLayout.minimumLineSpacing = itemSpacing
        }
    }
    /// default 1.f(no scaling), it ranges from 0.f to 1.f
    @IBInspectable open var itemZoomScale: CGFloat = 1.0 {
        didSet {
            flowLayout.zoomScale = itemZoomScale
        }
    }
    
    @IBInspectable open var hidesPageControl: Bool = false {
        didSet {
            pageControl?.isHidden = hidesPageControl
        }
    }
    @IBInspectable open var pageIndicatorTintColor: UIColor = UIColor.gray {
        didSet {
            pageControl?.pageIndicatorTintColor = pageIndicatorTintColor
        }
    }
    @IBInspectable open var currentPageIndicatorTintColor: UIColor = UIColor.white {
        didSet {
            pageControl?.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    /// current page index
    open var pageIndex: Int {
        return changeIndex(currentIndex())
    }
    /// current content offset
    open var contentOffset: CGPoint {
        let num = CGFloat(numberOfAddedCells() / 2)
        switch scrollDirection {
        case .vertical:
            return CGPoint(x: 0.0, y: max(0.0, collectionView.contentOffset.y - (flowLayout.itemSize.height + flowLayout.minimumLineSpacing) * num))
        default:
            return CGPoint(x: max(0.0, collectionView.contentOffset.x - (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * num), y: 0.0)
        }
    }
    /// infinite cycle
    @IBInspectable open private(set) var isInfiniteLoop: Bool = true
    /// load completed callback
    open var loadCompletion: (() -> Void)? = nil
    
    private var pageControl: UIPageControl!
    private var collectionView: UICollectionView!
    private var flowLayout: ZKCycleScrollViewFlowLayout!
    private var timer: Timer?
    private var numberOfItems: Int = 0
    private var fromIndex: Int = 0
    private var itemSizeFlag: Bool = false
    private var indexOffset: Int = 0
    private var configuredFlag: Bool = false
    private var tempIndex: Int = 0
    
    // MARK: - Open Func
    open func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> ZKCycleScrollViewCell {
        let indexPath = IndexPath(item: changeIndex(index), section: 0)
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    open func reloadData() {
        removeTimer()
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        collectionView.performBatchUpdates(nil) { _ in
            self.configuration()
            self.loadCompletion?()
        }
    }
    
    /// Call -beginUpdates and -endUpdates to update layout
    /// Allows multiple scrollDirection/itemSize/itemSpacing/itemZoomScale to be set simultaneously.
    open func beginUpdates() {
        tempIndex = pageIndex
        removeTimer()
    }
    
    open func endUpdates() {
        flowLayout.invalidateLayout()
        scrollToItem(at: tempIndex, animated: false)
        addTimer()
    }
    
    /// Scroll to page
    open func scrollToItem(at index: Int, animated: Bool) {
        let num = numberOfAddedCells()
        guard index >= 0 && index <= numberOfItems - 1 - num else {
            print("⚠️attempt to scroll to invalid index:\(index)")
            return
        }
        removeTimer()
        let idx = index + num / 2
        let position = scrollPosition()
        let indexPath = IndexPath(item: idx, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
        addTimer()
    }
    
    /// Returns the visible cell object at the specified index
    open func cellForItem(at index: Int) -> ZKCycleScrollViewCell? {
        let num = numberOfAddedCells()
        guard index >= 0 && index < numberOfItems - 1 - num else {
            return nil
        }
        let idx = index + num / 2
        let indexPath = IndexPath(item: idx, section: 0)
        let cell = collectionView.cellForItem(at: indexPath)
        return cell
    }

    // MARK: - Init
    public init(frame: CGRect, shouldInfiniteLoop infiniteLoop: Bool? = nil) {
        super.init(frame: frame)
        
        isInfiniteLoop = infiniteLoop ?? true
        initialization()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialization()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if itemSizeFlag {
            flowLayout.itemSize = itemSize
            flowLayout.headerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
            flowLayout.footerReferenceSize = CGSize(width: (bounds.width - itemSize.width) / 2, height: (bounds.height - itemSize.height) / 2)
        } else {
            flowLayout.itemSize = bounds.size
            flowLayout.headerReferenceSize = CGSize.zero
            flowLayout.footerReferenceSize = CGSize.zero
        }
        collectionView.frame = bounds
        pageControl.frame = CGRect(x: 0.0, y: bounds.height - 15.0, width: bounds.width, height: 15.0)
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil { removeTimer() }
    }
    
    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
        guard key == "scrollDirection" else {
            return;
        }
        let direction = value as! Int
        if direction == 1 {
            scrollDirection = .vertical
        } else {
            scrollDirection = .horizontal
        }
    }

    deinit {
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    // MARK: - Private Func
    private func initialization() {
        flowLayout = ZKCycleScrollViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        addSubview(pageControl);
        
        DispatchQueue.main.async {
            self.configuration()
            self.loadCompletion?()
        }
    }
    
    private func configuration() {
        fromIndex = 0
        indexOffset = 0
        configuredFlag = false
        
        guard numberOfItems > 1 else { return }
        
        let position = scrollPosition()
        if isInfiniteLoop {
            let indexPath = IndexPath(item: 2, section: 0)
            collectionView.scrollToItem(at: indexPath, at: position, animated: false)
        }
        
        addTimer()
        updatePageControl()
        
        configuredFlag = true
    }
    
    private func addTimer() {
        removeTimer()
        
        if numberOfItems < 2 || !isAutoScroll || autoScrollInterval <= 0.0 { return }
        timer = Timer.scheduledTimer(timeInterval: autoScrollInterval, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updatePageControl() {
        let num = numberOfAddedCells()
        pageControl.currentPage = 0
        pageControl.numberOfPages = max(0, numberOfItems - num)
        pageControl.isHidden = (hidesPageControl || pageControl.numberOfPages < 2)
    }
    
    private func numberOfAddedCells() -> Int {
        return isInfiniteLoop ? 4 : 0
    }

    @objc private func automaticScroll() {
        var index = currentIndex() + 1
        if !isInfiniteLoop && index >= numberOfItems  {
            index = 0
        }
        let position = scrollPosition()
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: true)
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scrollPosition() -> UICollectionView.ScrollPosition {
        switch scrollDirection {
        case .vertical:
            return .centeredVertically
        default:
            return .centeredHorizontally
        }
    }
    
    private func currentIndex() -> Int {
        guard numberOfItems > 0 else {
            return -1
        }
        
        var index = 0
        var minimumIndex = 0
        var maximumIndex = numberOfItems - 1
        
        if numberOfItems == 1 {
            return index
        }
        
        if isInfiniteLoop {
            minimumIndex = 1
            maximumIndex = numberOfItems - 2
        }

        switch scrollDirection {
        case .vertical:
            let height = flowLayout.itemSize.height + flowLayout.minimumLineSpacing
            index = Int((collectionView.contentOffset.y + height / 2) / height)
        default:
            let width = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
            index = Int((collectionView.contentOffset.x + width / 2) / width)
        }
        return min(maximumIndex, max(minimumIndex, index))
    }
    
    private func changeIndex(_ index: Int) -> Int {
        guard isInfiniteLoop && numberOfItems > 1 else {
            return index
        }
        
        var idx = index
        
        if index == 0 {
            idx = numberOfItems - 6
        } else if index == 1 {
            idx = numberOfItems - 5
        } else if index == numberOfItems - 2 {
            idx = 0
        } else if index == numberOfItems - 1 {
            idx = 1
        } else {
            idx = index - 2
        }
        return idx
    }
}

extension ZKCycleScrollView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didSelectItemAt:))) {
            removeTimer()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didSelectItemAt:))) {
            addTimer()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didSelectItemAt:))) {
            delegate.cycleScrollView!(self, didSelectItemAt: changeIndex(indexPath.item))
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = pageIndex
        
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollViewDidScroll(_:progress:))) {
            var total: CGFloat = 0.0
            var offset: CGFloat = 0.0
            let num = numberOfAddedCells()
            
            switch scrollDirection {
            case .vertical:
                total = CGFloat(numberOfItems - 1 - num) * (flowLayout.itemSize.height + flowLayout.minimumLineSpacing)
                offset = contentOffset.y.truncatingRemainder(dividingBy:((flowLayout.itemSize.height + flowLayout.minimumLineSpacing) * CGFloat(numberOfItems - num)))
            default:
                total = CGFloat(numberOfItems - 1 - num) * (flowLayout.itemSize.width + flowLayout.minimumLineSpacing)
                offset = contentOffset.x.truncatingRemainder(dividingBy:((flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * CGFloat(numberOfItems - num)))
            }
            let percent = Double(offset / total)
            let progress = percent * Double(numberOfItems - 1 - num)
            delegate.cycleScrollViewDidScroll!(self, progress: progress)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = currentIndex()
        
        if isInfiniteLoop {
            let position = scrollPosition()
            if index == 1 {
                let indexPath = IndexPath(item: numberOfItems - 3, section: 0)
                collectionView.scrollToItem(at: indexPath, at: position, animated: false)
            } else if index == numberOfItems - 2 {
                let indexPath = IndexPath(item: 2, section: 0)
                collectionView.scrollToItem(at: indexPath, at: position, animated: false)
            }
        }
        
        let toIndex = changeIndex(index)
        if let delegate = delegate, delegate.responds(to: #selector(ZKCycleScrollViewDelegate.cycleScrollView(_:didScrollFromIndex:toIndex:))) {
            delegate.cycleScrollView!(self, didScrollFromIndex: fromIndex, toIndex: toIndex)
        }
        fromIndex = toIndex
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard pageIndex == fromIndex else { return }
        
        let sum = velocity.x + velocity.y
        if sum > 0 {
            indexOffset = 1
        } else if sum < 0 {
            indexOffset = -1
        } else {
            indexOffset = 0
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let position = scrollPosition()
        var index = currentIndex() + indexOffset
        index = max(0, index)
        index = min(numberOfItems - 1, index)
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: position, animated: true)
        indexOffset = 0
    }
}

extension ZKCycleScrollView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItems = dataSource?.numberOfItems(in: self) ?? 0
        if isInfiniteLoop && numberOfItems > 1 {
            numberOfItems += numberOfAddedCells()
        }
        return numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = changeIndex(indexPath.item)
        return (dataSource?.cycleScrollView(self, cellForItemAt: index))!
    }
}
