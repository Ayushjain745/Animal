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
        view.backgroundColor = UIColor.systemBackground
    }
    
    // Sets up the table view's appearance and layout constraints
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none // Removes the default separator
        tableView.backgroundColor = UIColor.systemGroupedBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // Sets up the navigation bar button for viewing favorite images
    private func setupFavoritesButton() {
        let favoritesButton = UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(favoritesButtonTapped))
        navigationItem.rightBarButtonItem = favoritesButton
    }
    
    // Handles the action when the favorites button is tapped
    @objc private func favoritesButtonTapped() {
        let favoritesVC = FavoriteImagesViewController()
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    // Returns the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.animals.count
    }
    
    // Configures each cell in the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.animals[indexPath.row]
        cell.textLabel?.textColor = UIColor.label
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.backgroundColor = UIColor.secondarySystemGroupedBackground
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        // Adding custom separator for cell
        let separator = UIView(frame: CGRect(x: 15, y: cell.contentView.frame.height - 1, width: cell.contentView.frame.width - 30, height: 1))
        separator.backgroundColor = UIColor.separator
        cell.contentView.addSubview(separator)
        
        return cell
    }
    
    // Handles the action when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let animal = viewModel.animals[indexPath.row]
        let picturesVC = AnimalPicturesViewController(viewModel: AnimalPicturesViewModel(), animalName: animal)
        navigationController?.pushViewController(picturesVC, animated: true)
    }
    
    // Returns the height for each row in the table view
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Provides a custom footer view to remove extra separators
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
