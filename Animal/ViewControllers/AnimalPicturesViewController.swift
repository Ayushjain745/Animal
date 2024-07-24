//
//  AnimalPicturesViewController.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import UIKit

class AnimalPicturesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private let viewModel: AnimalPicturesViewModel
    private let collectionView: UICollectionView
    private let animalName: String
    
    init(viewModel: AnimalPicturesViewModel, animalName: String) {
        self.viewModel = viewModel
        self.animalName = animalName
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(animalName) Pictures"
        setupCollectionView()
        
        // Bind view model updates to UI
        viewModel.onPicturesUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        // Fetch pictures for the animal
        viewModel.fetchAnimalPictures(for: animalName)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        viewModel.fetchAnimalPictures(for: animalName)
    }
    
    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? UICollectionViewCell,
              let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let urlString = viewModel.pictures[indexPath.row]
        viewModel.toggleFavoriteStatus(for: urlString) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // Remove any existing subviews to avoid duplication
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let urlString = viewModel.pictures[indexPath.row]
        
        // Configure image view
        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        
        if let url = URL(string: urlString) {
            loadImage(from: url, into: cell)
        }
        
        // Add favorite button above the image
        let favoriteButton = UIButton(type: .system)
        favoriteButton.setTitle(viewModel.isFavorite(urlString) ? "❤️" : "♡", for: .normal)
        favoriteButton.frame = CGRect(x: cell.contentView.bounds.width - 40, y: 0, width: 40, height: 40)
        favoriteButton.backgroundColor = UIColor(white: 1, alpha: 0.7) // Add background for better visibility
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.clipsToBounds = true
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        favoriteButton.tag = indexPath.row // Tag button to identify the cell
        cell.contentView.addSubview(favoriteButton)
        
        // Bring favorite button to front
        cell.contentView.bringSubviewToFront(favoriteButton)
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlString = viewModel.pictures[indexPath.row]
        CoreDataManager.shared.addFavoriteImage(url: urlString, animalName: animalName)
    }
    
    private func loadImage(from url: URL, into cell: UICollectionViewCell) {
        if let cachedImage = ImageCache.shared.image(forKey: url.absoluteString) {
            let imageView = UIImageView(image: cachedImage)
            imageView.frame = cell.contentView.frame
            cell.contentView.addSubview(imageView)
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                if let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, forKey: url.absoluteString)
                    DispatchQueue.main.async {
                        let imageView = UIImageView(image: image)
                        imageView.frame = cell.contentView.frame
                        cell.contentView.addSubview(imageView)
                    }
                }
            }
            task.resume()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            viewModel.loadMorePictures()
        }
    }
}
