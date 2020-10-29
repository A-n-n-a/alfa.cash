//
//  FiltersTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 03.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol FiltersTableViewCellDelegate {
    func filterSelected(at indexPath: IndexPath)
}

class FiltersTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var section: Int = 0
    var delegate: FiltersTableViewCellDelegate?
    
    var filters: [Filter] = [] {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellClass: FilterCollectionViewCell.self)
        collectionView.reloadData()
    }
    
}

extension FiltersTableViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FilterCollectionViewCell.self), for: indexPath) as! FilterCollectionViewCell
        cell.filter = filters[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var paddings: CGFloat = UIDevice.current.iPhoneSE() ? 10 : 30
        let name = filters[indexPath.row].currency ?? filters[indexPath.row].subType.name
        let size: CGSize = name.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)])
        if section == 2 {
            paddings = 30
        }
        return CGSize(width: size.width + paddings, height: 40)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filterSelected(at: IndexPath(item: indexPath.item, section: section))
    }
}
