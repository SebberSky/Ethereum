//
//  ViewController.swift
//  Ethreum
//
//  Created by chawapon.kiatpravee on 14/8/2566 BE.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var coinList: [[String: String]] = []
    var searchResult: [[String: String]] = []
    let coinRequest = URLRequest(url: URL(string: "https://api.coingecko.com/api/v3/coins/list")!)
    var firstTimeLoaded = true
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstTimeLoaded {
            getCoinList()
        }
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func getCoinList() {
        let task = URLSession.shared.dataTask(with: self.coinRequest) { data, _, _ in
            if let data = data, let decoder = try? JSONDecoder().decode([[String: String]].self, from: data) {
                DispatchQueue.main.async {
                    self.coinList = decoder
                    self.firstTimeLoaded = false
                }
            }
        }
        task.resume()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CoinCell
        cell.titleLabel.text = searchResult[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = searchResult[indexPath.row]
        navigateToInfoScreen(coinName: data["name"]!, coinId: data["id"]!)
    }
    
    func navigateToInfoScreen(coinName: String, coinId: String) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoinDetailsViewController") as! CoinDetailsViewController
        vc.coinId = coinId
        vc.title = coinName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var inputString = (searchBar.text ?? "") + text
        if text == "" {
            inputString.removeLast()
        }
        let _searchResult = coinList.filter {
            let lowercaseName = $0["name"] ?? ""
            return lowercaseName.contains(inputString.lowercased())
        }
        searchResult = _searchResult
        tableView.reloadData()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResult = []
        tableView.reloadData()
    }
}

class CoinCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
