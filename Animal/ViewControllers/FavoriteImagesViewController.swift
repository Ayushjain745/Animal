//
//  FavoriteImagesViewController.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import UIKit

class FavoriteImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private let viewModel = FavoriteImagesViewModel()
    private let collectionView: UICollectionView
    private let noFavoritesLabel: UILabel
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        noFavoritesLabel = UILabel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorite Pictures"
        view.backgroundColor = UIColor.systemBackground
        setupCollectionView()
        setupNoFavoritesLabel()
        setupFilterButton()
        viewModel.onImagesUpdate = { [weak self] in
            self?.collectionView.reloadData()
            self?.updateNoFavoritesLabel()
        }
        viewModel.fetchFavoriteImages()
    }
    
    // Sets up the collection view's appearance and layout constraints
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FavoriteImageCell.self, forCellWithReuseIdentifier: "FavoriteImageCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.systemBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // Sets up the "No favorites" label
    private func setupNoFavoritesLabel() {
        noFavoritesLabel.text = "No favorites"
        noFavoritesLabel.textColor = UIColor.secondaryLabel
        noFavoritesLabel.textAlignment = .center
        noFavoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noFavoritesLabel)
        
        NSLayoutConstraint.activate([
            noFavoritesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noFavoritesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noFavoritesLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            noFavoritesLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        noFavoritesLabel.isHidden = true // Initially hidden
    }
    
    // Updates the visibility of the "No favorites" label based on image count
    private func updateNoFavoritesLabel() {
        noFavoritesLabel.isHidden = !viewModel.filteredImages.isEmpty
    }
    
    // Sets up the filter button in the navigation bar
    private func setupFilterButton() {
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterButtonTapped))
        navigationItem.rightBarButtonItem = filterButton
    }
    
    // Displays an action sheet for filtering images by animal type
    @objc private func filterButtonTapped() {
        let alert = UIAlertController(title: "Filter by Animal", message: nil, preferredStyle: .actionSheet)
        let animals = ["All", "Elephant", "Lion", "Fox", "Dog", "Shark", "Turtle", "Whale", "Penguin"].sorted()
        animals.forEach { animal in
            alert.addAction(UIAlertAction(title: animal, style: .default, handler: { [weak self] _ in
                self?.viewModel.filterImages(by: animal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Configure popover presentation controller for iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // Returns the number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredImages.count
    }
    
    // Configures each cell in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteImageCell", for: indexPath) as! FavoriteImageCell
        let favoriteImage = viewModel.filteredImages[indexPath.row]
        
        // Start loading indicator
        cell.startLoading()
        if let url = URL(string: favoriteImage.url ?? "") {
            loadImage(from: url, into: cell.imageView) {
                cell.stopLoading()
            }
        } else {
            cell.stopLoading()
        }
        
        return cell
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
}
