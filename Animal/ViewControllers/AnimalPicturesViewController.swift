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
        collectionView.register(AnimalPictureCell.self, forCellWithReuseIdentifier: "AnimalPictureCell")
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimalPictureCell", for: indexPath) as! AnimalPictureCell
        let urlString = viewModel.pictures[indexPath.row]
        
        // Configure image view
        if let url = URL(string: urlString) {
            loadImage(from: url, into: cell.imageView)
        }
        
        // Configure favorite button
        cell.favoriteButton.setTitle(viewModel.isFavorite(urlString) ? "❤️" : "♡", for: .normal)
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let urlString = viewModel.pictures[indexPath.row]
        viewModel.toggleFavoriteStatus(for: urlString) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        if let cachedImage = ImageCache.shared.image(forKey: url.absoluteString) {
            imageView.image = cachedImage
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                if let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, forKey: url.absoluteString)
                    DispatchQueue.main.async {
                        imageView.image = image
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
