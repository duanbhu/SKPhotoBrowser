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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSKPhotoLoadingDidEndNotification(_:)),
                                               name: NSNotification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION),
                                               object: nil)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        imageScrollView.prepareForReuse()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        imageScrollView.frame = contentView.bounds
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Notification
    @objc open func handleSKPhotoLoadingDidEndNotification(_ notification: Notification) {
        guard let photo = notification.object as? SKPhotoProtocol else {
            return
        }
        
        DispatchQueue.main.async(execute: {
            let page = self.imageScrollView
            
            if photo.underlyingImage != nil {
                page.displayImage(complete: true)
            } else {
                page.displayImageFailure()
            }
        })
    }
}
