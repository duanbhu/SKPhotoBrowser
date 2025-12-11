//
//  DHPhotoCollectionCell.swift
//  SKPhotoBrowser
//
//  Created by Duanhu on 2025/12/11.
//

import UIKit

open class DHPhotoCollectionCell: UICollectionViewCell {
    
    open lazy var imageScrollView: SKZoomingScrollView = {
        let scrollView = SKZoomingScrollView(frame: contentView.bounds)
        return scrollView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageScrollView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        imageScrollView.frame = contentView.bounds
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
