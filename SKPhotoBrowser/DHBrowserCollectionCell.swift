//
//  DHPhotoBrowserView.swift
//  SKPhotoBrowser
//
//  Created by Duanhu on 2025/12/10.
//  Copyright © 2025 suzuki_keishi. All rights reserved.
//

import UIKit

public extension Notification.Name {
    static let sKZoomingScrollViewSingleTap = Notification.Name("sKZoomingScrollViewSingleTap")
    
    static let skToolbarToolAction = Notification.Name("skToolbarToolAction")
}

open class DHBrowserCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    open var photos: [SKPhotoProtocol] = [] {
        didSet {
            collectionView.reloadData()
            // 确保在数据加载时，如果 record.image_list 为空，不会导致崩溃
            let count = photos.count
            paginationView.update(currentPageIndex, photosCount: count)
            
            // 确保从第一页开始显示 (如果需要的话)
            if currentPageIndex != 0 {
                collectionView.scrollToPage(0, animated: false)
                currentPageIndex = 0
            }
        }
    }
    
    // 确保使用我们之前讨论过的 DHPhotoCollectionView
    private lazy var collectionView: DHPhotoCollectionView = {
        // 使用 bounds 作为 frame
        let view = DHPhotoCollectionView(frame: contentView.bounds)
        view.register(DHPhotoCollectionCell.self, forCellWithReuseIdentifier: "DHPhotoCollectionCell")
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private var currentPageIndex: Int = 0
    
    private lazy var paginationView: SKPaginationView = {
        let paginationView = SKPaginationView(frame: contentView.bounds, browser: nil)
        return paginationView
    }()
    
    private lazy var toolbar: SKToolbar = {
        let toolbar = SKToolbar(frame: .zero)
        return toolbar
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    open func makeUI() {
        contentView.backgroundColor = .black
        contentView.addSubview(collectionView)
        contentView.addSubview(paginationView)
        contentView.addSubview(toolbar)
       
        collectionView.frame = contentView.bounds
        paginationView.frame = CGRect(x: 0, y: contentView.bounds.height - 100, width: contentView.bounds.width, height: 100)
        toolbar.frame = frameForToolbarAtOrientation()
        
        setupToolbar()
    }
    
    func setupToolbar() {
        toolbar.backgroundColor = .clear
        toolbar.clipsToBounds = true
        toolbar.isTranslucent = true
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        
        toolbar.toolActionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonPressed))
        toolbar.toolActionButton.tintColor = UIColor.white
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        if SKPhotoBrowserOptions.displayAction {
            items.append(toolbar.toolActionButton)
        }
        toolbar.setItems(items, animated: false)
    }
    
    @objc func actionButtonPressed(ignoreAndShare: Bool) {
        let photo = photos[currentPageIndex]
        NotificationCenter.default.post(name: .skToolbarToolAction, object: nil, userInfo: ["photo": photo])
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
        paginationView.frame = CGRect(x: 0, y: contentView.bounds.height - 100, width: contentView.bounds.width, height: 100)
        toolbar.frame = frameForToolbarAtOrientation()
    }
    
    func frameForToolbarAtOrientation() -> CGRect {
        let offset: CGFloat = {
            if #available(iOS 11.0, *) {
                return contentView.safeAreaInsets.bottom
            } else {
                return 15
            }
        }()
        
        let height: CGFloat = {
            if #available(iOS 26.0, *) {
                return 48
            } else {
                return 44
            }
        }()
        return CGRect(x: 0, y: contentView.bounds.height - 100, width: contentView.bounds.width, height: height)
    }
}

// MARK: - UICollectionViewDataSource

extension DHBrowserCollectionCell: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DHPhotoCollectionCell", for: indexPath) as! DHPhotoCollectionCell
        // 确保 photo 属性设置正确
        cell.imageScrollView.photo = photos[indexPath.item]
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
}

// MARK: - UICollectionViewDelegate

extension DHBrowserCollectionCell: UICollectionViewDelegate {
    // 可以在这里添加 Cell 点击事件等其他代理方法
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("点击了")
    }
}

// MARK: - UIScrollViewDelegate (用于监听滚动完成)
extension DHBrowserCollectionCell: UIScrollViewDelegate {
    /// 滚动停止（拖拽后减速停止）时更新分页指示器
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 使用 DHPhotoCollectionView 的 currentPage 属性
        guard let pb = scrollView as? DHPhotoCollectionView else { return }
        
        let page = pb.currentPage
        if currentPageIndex != page {
            currentPageIndex = page
            paginationView.update(page, photosCount: photos.count)
        }
    }

    /// 滚动停止（通过代码 scrollToPage 或 setContentOffset 停止）时更新分页指示器
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // 使用 DHPhotoCollectionView 的 currentPage 属性
        guard let pb = scrollView as? DHPhotoCollectionView else { return }
        
        let page = pb.currentPage
        if currentPageIndex != page {
            currentPageIndex = page
            paginationView.update(page, photosCount: photos.count)
        }
    }
}
