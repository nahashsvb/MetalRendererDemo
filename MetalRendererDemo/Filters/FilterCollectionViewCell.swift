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

        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let imageView = UIImageView()

    override func prepareForReuse() {
        super.prepareForReuse()

        self.imageView.isHidden = true
    }
}
