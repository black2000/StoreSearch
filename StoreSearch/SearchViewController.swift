//
//  ViewController.swift
//  StoreSearch
//
//  Created by lapshop on 2/8/21.
//

import UIKit

class SearchViewController: UIViewController {
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var tableView: UITableView!
   var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil), forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        tableView.register(UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil), forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        tableView.register(UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil), forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }

    func iTunesURL(searchText:String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    func perfromStoreReuquest(with url : URL) -> Data? {
        do {
             return try Data(contentsOf: url)
        } catch  {
            print(error.localizedDescription)
            showNetworkError()
            return nil
        }
    }
    
    func parse(data: Data) -> [SearchResult] {
        
        do {
           let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch {
            print("erorr parsing \(error)")
            return []
        }
    }
    
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .destructive, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension SearchViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty {
            
            searchResults = []
            hasSearched = true
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
            let url = iTunesURL(searchText: searchBar.text!)
            let queue = DispatchQueue.global()
            
            queue.async {
                if let data = self.perfromStoreReuquest(with: url) {
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort {
                       return $0.name.localizedStandardCompare($1.name) == .orderedAscending
                   }
                
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    
                return
               }
            }
        }
        
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    
}

extension SearchViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
          return 1
        }
        else if !hasSearched {
            return 0
        }else if searchResults.count == 0 {
            return 1
        }else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            
            spinner.startAnimating()
            return cell
        }
        else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            
            if  searchResult.artist.isEmpty {
                cell.artistNameLabel.text = "unknown"
            }else {
                cell.artistNameLabel.text = String(format: "%@ (%@)",searchResult.artist, searchResult.type)
            }
            

            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }
        return indexPath
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController {
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    
}


