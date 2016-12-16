//
//  RecentSearchTableViewController.swift
//  Smashtag
//
//  Created by 李天培 on 2016/12/2.
//  Copyright © 2016年 lee. All rights reserved.
//

import UIKit

let UserDefaultKeyWordOfRecentSearch = "Recent Search"


class RecentSearchTableViewController: UITableViewController {
    
    private var recentSearchTerm = [(date: Date, term: String)]() {
        didSet {
            recentSearchTerm.sort { $0 > $1 }
            tableView.reloadData()
            if oldValue.count > recentSearchTerm.count {
                UserDefaults.standard.set(recentSearchTerm.map { [$0.term : $0.date]}, forKey: UserDefaultKeyWordOfRecentSearch)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let terms = UserDefaults.standard.dictionary(forKey: UserDefaultKeyWordOfRecentSearch) as? [String: Date] {
            recentSearchTerm = terms.map { ($0.value, $0.key) }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recentSearchTerm.count
    }

    private struct StoryBoard {
        static let SearchTermCellIdentifier = "Recent Search Term"
        static let ResearchTermSegueIdentifier = "Search Term"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.SearchTermCellIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = recentSearchTerm[indexPath.row].term
        cell.detailTextLabel?.text = DateFormatter.detailFormatter.string(from: recentSearchTerm[indexPath.row].date)
        

        return cell
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            recentSearchTerm.remove(at: indexPath.row)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case StoryBoard.ResearchTermSegueIdentifier:
                if let ttvc = segue.destination as? TweetTableViewController {
                    // set information
                    ttvc.searchText = (sender as? UITableViewCell)?.textLabel?.text
                }
            default:
                break
            }
        }
    }
 

}

extension DateFormatter {
    static var detailFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
