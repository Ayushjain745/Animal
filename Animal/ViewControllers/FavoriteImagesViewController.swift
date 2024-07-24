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
    
    init() {
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
        title = "Favorite Pictures"
        setupCollectionView()
        setupFilterButton()
        viewModel.onImagesUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.fetchFavoriteImages()
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
    }
    
    private func setupFilterButton() {
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterButtonTapped))
        navigationItem.rightBarButtonItem = filterButton
    }
    
    @objc private func filterButtonTapped() {
        let alert = UIAlertController(title: "Filter by Animal", message: nil, preferredStyle: .actionSheet)
        let animals = ["All", "Elephant", "Lion", "Fox", "Dog", "Shark", "Turtle", "Whale", "Penguin"]
        animals.forEach { animal in
            alert.addAction(UIAlertAction(title: animal, style: .default, handler: { [weak self] _ in
                self?.viewModel.filterImages(by: animal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let favoriteImage = viewModel.filteredImages[indexPath.row]
        if let url = URL(string: favoriteImage.url ?? "") {
            loadImage(from: url, into: cell)
        }
        return cell
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
}

