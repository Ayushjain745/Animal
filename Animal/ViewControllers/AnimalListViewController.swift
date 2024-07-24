//
//  AnimalListViewController.swift
//  Animal
//
//  Created by Ayush Jain on 24/07/24.
//

import UIKit

class AnimalListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let viewModel = AnimalListViewModel()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFavoritesButton()
        title = "Animals"
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupFavoritesButton() {
        let favoritesButton = UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(favoritesButtonTapped))
        navigationItem.rightBarButtonItem = favoritesButton
    }
    
    @objc private func favoritesButtonTapped() {
        let favoritesVC = FavoriteImagesViewController()
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.animals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.animals[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let animal = viewModel.animals[indexPath.row]
        let picturesVC = AnimalPicturesViewController(viewModel: AnimalPicturesViewModel(), animalName: animal)
        navigationController?.pushViewController(picturesVC, animated: true)
    }
}

