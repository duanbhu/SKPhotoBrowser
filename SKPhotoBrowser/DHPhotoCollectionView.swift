//
//  File.swift
//  SKPhotoBrowser
//
//  Created by Duanhu on 2025/12/11.
//

import UIKit

class DHPhotoCollectionView: UICollectionView {
    // MARK: - Properties
    
    /// 自定义布局
    private(set) var customLayout: DHPhotoCollectionViewFlowLayout?
    
    // MARK: - Initialization
    
    convenience init(frame: CGRect) {
        let layout = DHPhotoCollectionViewFlowLayout()
        self.init(frame: frame, collectionViewLayout: layout)
        self.customLayout = layout
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
        
        // 如果传入的是我们自定义的布局，保存引用
        if let customLayout = layout as? DHPhotoCollectionViewFlowLayout {
            self.customLayout = customLayout
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = false
        alwaysBounceHorizontal = false
        decelerationRate = .fast
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    /// 获取当前位于中心位置的 Cell（支持横向 / 纵向滚动）
    var centerCell: UICollectionViewCell? {
        let visibleCells = self.visibleCells
        guard !visibleCells.isEmpty else { return nil }

        let isVertical = customLayout?.scrollDirection == .vertical

        if isVertical {
            let centerY = contentOffset.y + bounds.height * 0.5
            return visibleCells.min { cell1, cell2 in
                let distance1 = abs(cell1.center.y - centerY)
                let distance2 = abs(cell2.center.y - centerY)
                return distance1 < distance2
            }
        } else {
            let centerX = contentOffset.x + bounds.width * 0.5
            return visibleCells.min { cell1, cell2 in
                let distance1 = abs(cell1.center.x - centerX)
                let distance2 = abs(cell2.center.x - centerX)
                return distance1 < distance2
            }
        }
    }
    
    /// 滚动到指定页面
    /// - Parameter page: 页面索引（从0开始）
    func scrollToPage(_ page: Int, animated: Bool = false) {
        let spacing = customLayout?.minimumLineSpacing ?? 0

        switch customLayout?.scrollDirection {
        case .vertical:
            let pageHeight = bounds.height + spacing
            let offsetY = pageHeight * CGFloat(page)
            setContentOffset(CGPoint(x: 0, y: offsetY), animated: animated)

        case .horizontal:
            let pageWidth = bounds.width + spacing
            let offsetX = pageWidth * CGFloat(page)
            setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)

        default:
            break
        }
    }
    
    /// 获取当前页面索引
    var currentPage: Int {
        switch customLayout?.scrollDirection {
        case .vertical:
            guard bounds.height > 0 else { return 0 }
            let spacing = customLayout?.minimumLineSpacing ?? 0
            let pageHeight = bounds.height + spacing
            let page = Int((contentOffset.y + pageHeight * 0.5) / pageHeight)
            return max(0, page)
        case .horizontal:
            guard bounds.width > 0 else { return 0 }
            let spacing = customLayout?.minimumLineSpacing ?? 0
            let pageWidth = bounds.width + spacing
            let page = Int((contentOffset.x + pageWidth * 0.5) / pageWidth)
            return max(0, page)
        case _:
            return 0
        }
    }
    
    // MARK: - Hit Test
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        // 当点击到 UISlider 时，禁用滚动以避免手势冲突
        if let _ = view as? UISlider {
            isScrollEnabled = false
        } else {
            isScrollEnabled = true
        }
        
        return view
    }
    
    // MARK: - 触摸事件处理（可选增强）
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 触摸开始时，确保滚动可用
        isScrollEnabled = true
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 触摸结束时，恢复滚动状态
        isScrollEnabled = true
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 触摸取消时，恢复滚动状态
        isScrollEnabled = true
        super.touchesCancelled(touches, with: event)
    }
    
    // MARK: - 滚动到中心 Cell（增强功能）
    /// 平滑滚动到最近的 Cell（用于非分页模式下的精确对齐）
    func scrollToNearestCell(animated: Bool = true) {
        guard let centerCell = centerCell,
              let indexPath = indexPath(for: centerCell) else { return }
        
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
}
