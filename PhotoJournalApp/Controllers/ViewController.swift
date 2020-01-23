//
//  ViewController.swift
//  PhotoJournalApp
//
//  Created by Brendon Cecilio on 1/23/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var images = [ImageObject]()
    private var imagePickerController = UIImagePickerController()
    private var imagePersistance = PersistenceHelper.init(filename: "images.plist")
    private var selectedImages : UIImage? {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func loadImages() {
        do {
            images = try imagePersistance.loadImages()
        } catch {
            print("loading error: \(error)")
        }
    }
    
    @IBAction func addImageButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camerAction = UIAlertAction(title: "Camera", style: .default) {
            [weak self] alertAction in self?.showImageController(isCameraSelected: true)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) {
            [weak self] alertAction in self?.showImageController(isCameraSelected: false)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            alertController.addAction(camerAction)
        }
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
    }
    
    private func showImageController(isCameraSelected: Bool) {
        imagePickerController.sourceType = .photoLibrary
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        present(imagePickerController, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell else {
            fatalError("could not downcast ImageCollectionViewCell")
        }
        let cellImage = images[indexPath.row]
        cell.configureCell(for: cellImage)
        cell.layer.cornerRadius = 7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.30
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

