//
//  FavoriteImageCell.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import UIKit

class FavoriteImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    private let loader = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupLoader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets up the image view's appearance and layout constraints
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // Sets up the loading indicator's appearance and layout constraints
    private func setupLoader() {
        loader.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // Starts the loading indicator
    func startLoading() {
        loader.startAnimating()
    }
    
    // Stops the loading indicator
    func stopLoading() {
        loader.stopAnimating()
    }
}

