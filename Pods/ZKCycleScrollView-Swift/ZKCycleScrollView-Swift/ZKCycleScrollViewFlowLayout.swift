//
//  ZKCycleScrollViewFlowLayout.swift
//  ZKCycleScrollViewDemo
//
//  Created by bestdew on 2019/3/22.
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

open class ZKCycleScrollViewFlowLayout: UICollectionViewFlowLayout {

    open var zoomScale: CGFloat = 1.0
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes: [UICollectionViewLayoutAttributes] = NSArray(array: super.layoutAttributesForElements(in: rect) ?? [], copyItems: true) as! [UICollectionViewLayoutAttributes]
        if let collectionView = collectionView {
            switch scrollDirection {
            case .vertical:
                let offset = collectionView.bounds.midY;
                let distanceForScale = itemSize.height + minimumLineSpacing;
                
                for attr in attributes {
                    var scale: CGFloat = 0.0;
                    let distance = abs(offset - attr.center.y)
                    if distance >= distanceForScale {
                        scale = zoomScale;
                    } else if distance == 0.0 {
                        scale = 1.0
                        attr.zIndex = 1
                    } else {
                        scale = zoomScale + (distanceForScale - distance) * (1.0 - zoomScale) / distanceForScale
                    }
                    attr.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            default:
                let offset = collectionView.bounds.midX;
                let distanceForScale = itemSize.width + minimumLineSpacing;

                for attr in attributes {
                    var scale: CGFloat = 0.0;
                    let distance = abs(offset - attr.center.x)
                    if distance >= distanceForScale {
                        scale = zoomScale;
                    } else if distance == 0.0 {
                        scale = 1.0
                        attr.zIndex = 1
                    } else {
                        scale = zoomScale + (distanceForScale - distance) * (1.0 - zoomScale) / distanceForScale
                    }
                    attr.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
        }
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var point = proposedContentOffset
        if let collectionView = collectionView {
            switch scrollDirection {
            case .vertical:
                /// 计算出最终显示的矩形框
                let rect = CGRect(x: 0.0, y: point.y, width: collectionView.bounds.width, height: collectionView.bounds.height)
                /// 计算collectionView最中心点的y值
                let centerY = point.y + collectionView.bounds.size.height * 0.5
                /// 存放最小的间距值
                var minDelta = CGFloat(MAXFLOAT)
                /// 获得super已经计算好的布局属性
                if let attributes = super.layoutAttributesForElements(in: rect) {
                    for attr in attributes {
                        if abs(minDelta) > abs(attr.center.y - centerY) {
                            minDelta = attr.center.y - centerY
                        }
                    }
                }
                /// 修改原有的偏移量
                point.y += minDelta
            default:
                /// 计算出最终显示的矩形框
                let rect = CGRect(x: point.x, y: 0.0, width: collectionView.bounds.width, height: collectionView.bounds.height)
                /// 计算collectionView最中心点的y值
                let centerX = point.x + collectionView.bounds.size.width * 0.5
                /// 存放最小的间距值
                var minDelta = CGFloat(MAXFLOAT)
                /// 获得super已经计算好的布局属性
                if let attributes = super.layoutAttributesForElements(in: rect) {
                    for attr in attributes {
                        if abs(minDelta) > abs(attr.center.x - centerX) {
                            minDelta = attr.center.x - centerX
                        }
                    }
                }
                /// 修改原有的偏移量
                point.x += minDelta
            }
        }
        return point
    }
}
