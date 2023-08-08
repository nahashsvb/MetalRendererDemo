//
//  Filters.swift
//  MetalRendererDemo
//
//  Created by Serhii Borysov on 08/08/2023.
//

import Foundation
import UIKit

final class FiltersViewController: UIViewController {
    
    init(device: MTLDevice, filters: [MetalTextureFilter], currentTexture:MTLTexture, onSelectFilter: @escaping ((MetalTextureFilter) -> Void)) {
        self.device = device
        self.filters = filters
        self.currentTexture = currentTexture
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
    private var previews: [UIImage] = []
    private var activeFilterIndex: Int = 0
    private var currentTexture: MTLTexture? = nil
    private var offscreenRenderer: OffscreenRenderer? = nil
    
    lazy var colelctionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.layer.borderWidth = 1.5
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
        guard let device = device else {
            fatalError("Metal device is missing")
        }
        
        offscreenRenderer = OffscreenRenderer(device: device)
        view.addSubview(colelctionView)
        colelctionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.renderPreviews { [weak self] in
            self?.colelctionView.reloadData()
            self?.colelctionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func renderPreviews(completion: @escaping (() -> Void)) {
        guard let offscreenRenderer = offscreenRenderer else {
            fatalError("offscreenRenderer is missing")
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let currentTexture = currentTexture else { return }
            
            for filter in filters {
                let image = offscreenRenderer.renderOffscreen(size: CGSize(width: 100, height: 100),
                                                              sourceTexture: currentTexture,
                                                              with: filter)
                if let image = image {
                    previews.append(image)
                } else {
                    fatalError("failed to render preview")
                }
            }
            
            guard previews.count == filters.count else {
                fatalError("previews.count != filters.count")
            }
            DispatchQueue.main.async {
                completion()
            }
        }
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
        guard previews.count == filters.count else {
            return cell
        }
        let image = self.previews[indexPath.row]
        cell.imageView.image = image
        cell.imageView.isHidden = false
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
        
    }
}
