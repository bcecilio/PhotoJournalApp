//
//  ImageCollectionViewCell.swift
//  PhotoJournalApp
//
//  Created by Brendon Cecilio on 1/23/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import UIKit

protocol ImageCellDelegate: AnyObject {
    func alert(_ imageCell: ImageCollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelView: UILabel!
    
    weak var delegate: ImageCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20.0
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    public func configureCell(imageObject: ImageObject) {
        // converting data to UIImage
        guard let image = UIImage(data: imageObject.imageData) else {
            return
        }
        imageView.image = image
        imageView.layer.cornerRadius = 7
        labelView.text = imageObject.description
        labelView.backgroundColor = .white
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate?.alert(self)
    }
    
}
