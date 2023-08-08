//
//  Filters.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 08/08/2023.
//

import Foundation
import UIKit

final class FiltersViewController: UIViewController {
    
    init(device: MTLDevice, filters: [MetalTextureFilter], onSelectFilter: @escaping ((MetalTextureFilter) -> Void)) {
        self.device = device
        self.filters = filters
        self.onSelectFilter = onSelectFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private var device: MTLDevice? = nil
    private var onSelectFilter: ((MetalTextureFilter) -> Void)?
    private var filters: [MetalTextureFilter] = []
    private var activeFilterIndex: Int = 0
    
    lazy var colelctionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.4)
        collectionView.layer.borderWidth = 1.5
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.allowsSelection = true
        collectionView.register(
            FilterCollectionViewCell.self,
            forCellWithReuseIdentifier: "FilterCollectionViewCell"
        )

        return collectionView
    }()
    
    private func setup() {
        view.addSubview(colelctionView)
        colelctionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        colelctionView.reloadData()
    }
}

extension FiltersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
}

extension FiltersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = 80.0
        return CGSize(width: size, height: size)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        10.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        10.0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activeFilterIndex = indexPath.item
        let filter = self.filters[activeFilterIndex]
        self.onSelectFilter?(filter)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselect")
    }
}
