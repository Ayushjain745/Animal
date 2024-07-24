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
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(animalName) Pictures"
        view.backgroundColor = UIColor.systemBackground
        setupCollectionView()
        
        // Bind view model updates to UI
        viewModel.onPicturesUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        // Fetch pictures for the animal
        viewModel.fetchAnimalPictures(for: animalName)
    }
    
    // Sets up the collection view's appearance and layout constraints
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AnimalPictureCell.self, forCellWithReuseIdentifier: "AnimalPictureCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.systemBackground
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add pull-to-refresh functionality
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    // Handles the action when the user performs a pull-to-refresh
    @objc private func refreshData() {
        viewModel.fetchAnimalPictures(for: animalName)
    }
    
    // Returns the number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pictures.count
    }
    
    // Configures each cell in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimalPictureCell", for: indexPath) as! AnimalPictureCell
        let urlString = viewModel.pictures[indexPath.row]
        
        // Configure image view with loader
        cell.startLoading()
        if let url = URL(string: urlString) {
            loadImage(from: url, into: cell.imageView) {
                cell.stopLoading()
            }
        } else {
            cell.stopLoading()
        }
        
        // Configure favorite button
        cell.favoriteButton.setTitle(viewModel.isFavorite(urlString) ? "❤️" : "♡", for: .normal)
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // Handles the action when the favorite button is tapped
    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let urlString = viewModel.pictures[indexPath.row]
        viewModel.toggleFavoriteStatus(for: urlString, animalName: animalName) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    // Loads an image from a URL into the specified image view
    private func loadImage(from url: URL, into imageView: UIImageView, completion: @escaping () -> Void) {
        if let cachedImage = ImageCache.shared.image(forKey: url.absoluteString) {
            imageView.image = cachedImage
            completion()
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                if let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, forKey: url.absoluteString)
                    DispatchQueue.main.async {
                        imageView.image = image
                        completion()
                    }
                }
            }
            task.resume()
        }
    }
    
    // Detects when the user scrolls the collection view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        // Loads more pictures when the user scrolls to the bottom
        if offsetY > contentHeight - scrollView.frame.height {
            viewModel.loadMorePictures()
        }
    }
}
