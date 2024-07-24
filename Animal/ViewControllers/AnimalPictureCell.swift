//
//  AnimalPictureCell.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import UIKit

class AnimalPictureCell: UICollectionViewCell {
    let imageView = UIImageView()
    let favoriteButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupFavoriteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupFavoriteButton() {
        favoriteButton.setTitle("♡", for: .normal)
        favoriteButton.backgroundColor = UIColor(white: 1, alpha: 0.7)
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.clipsToBounds = true
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
        
        contentView.bringSubviewToFront(favoriteButton)
    }
}
