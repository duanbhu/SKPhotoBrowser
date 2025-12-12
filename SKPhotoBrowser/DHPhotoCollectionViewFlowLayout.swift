//
//  DHPhotoCollectionViewFlowLayout.swift
//  SKPhotoBrowser
//
//  Created by Duanhu on 2025/12/11.
//

import UIKit

class DHPhotoCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = .zero
        scrollDirection = .horizontal
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        // 设置 item 大小为 collectionView 的尺寸
        itemSize = collectionView.bounds.size
    }
}
