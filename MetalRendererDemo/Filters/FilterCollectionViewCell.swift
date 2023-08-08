//
//  FilterCollectionViewCell.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 08/08/2023.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        self.imageView.backgroundColor = UIColor.clear

    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 8.0
    }

    // MARK: Internal

    let imageView = UIImageView()

    override func prepareForReuse() {
        super.prepareForReuse()

        self.imageView.isHidden = true
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            if newValue == true {
                self.contentView.layer.borderWidth = 2.0
                self.contentView.layer.borderColor = UIColor.cyan.cgColor
            } else {
                self.contentView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
}
