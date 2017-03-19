//
//  TableViewController.swift
//  Fitsapp Test
//
//  Created by Theodore S. Walker on 3/18/17.
//  Copyright © 2017 TheoWalker. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // updates sorting mode when it is changed
    @IBAction func sorting(_ sender: UISegmentedControl) {
        // by date
        if sender.selectedSegmentIndex == 0 {
            sorting = 0
        }
        // by priority
        else {
            sorting = 1
        }
        queryItems()
    }
    
    // defines lists representing various item field values
    var itemNames = [String]()
    var itemImportances = [Int]()
    var itemDates = [Date]()
    
    // default sorting state (by date)
    var sorting = 0
    
    override func viewDidLoad() {
        
        // setup from parent class
        super.viewDidLoad()
        
        // filter through items and fill corresponding lists
        queryItems()
        
        searchBar.delegate = self
    }

    // give table 1 section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // give table appropriate number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemNames.count
    }
    
    func queryItems()
    {
        // ensure lists are empty to prevent bugs
        itemNames = []
        itemImportances = []
        itemDates = []
        
        // sort by date
        if sorting == 0 {
            let realm = try! Realm()
            let itemList = realm.objects(Item.self).filter("name CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
            
            // iterate through items and append to lists
            for item in itemList
            {
                itemNames.append(item.name)
                itemImportances.append(item.importance)
                itemDates.append(item.date)
                
                // avoid bugs
                tableView.reloadData()
            }
        }
            
        // sort by priority
        else {
            let realm = try! Realm()
            let itemList = realm.objects(Item.self).filter("name CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "importance", ascending: false)

            // iterate through items and append to lists
            for item in itemList
            {
                itemNames.append(item.name)
                itemImportances.append(item.importance)
                itemDates.append(item.date)
                
                // avoid bugs
                tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // identify cell attributes
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        // allow date to be simplified into string
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        // designate cell labels
        cell.nameLabel.text = itemNames[indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: itemDates[indexPath.row])
        
        // give cell appropriate background color
        cell.backgroundColor = determineColor(importance: itemImportances[indexPath.row])
        
        // gray out labels and remove background color if event already happened
        if determineDistanceInDays(itemDate: itemDates[indexPath.row]) < 0 {
            cell.nameLabel.alpha = 0.5
            cell.dateLabel.alpha = 0.5
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // cell is deleted
        if editingStyle == .delete {
            
            let realm = try! Realm()
            
            // sort by date
            if sorting == 0 {
                let items = realm.objects(Item.self).filter("name CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
                
                // delete data from Realm
                try! realm.write {
                    realm.delete(items[indexPath.row])
                }
            }
                
            // sort by priority
            else {
                let items = realm.objects(Item.self).filter("name CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "importance", ascending: false)
                
                // delete data from Realm
                try! realm.write {
                    realm.delete(items[indexPath.row])
                }
            }
            
            // update table
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            queryItems()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath) {
        
        let realm = try! Realm()
        let currentItem: Item
        
        // sort by date
        if sorting == 0 {
            let items = realm.objects(Item.self).filter("name CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
            currentItem = items[indexPath.row]
        }
            
        // sort by priority
        else {
            let items = realm.objects(Item.self).filter("name CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "importance", ascending: false)
            currentItem = items[indexPath.row]
        }
        
        // initialize Storyboard
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // initialize target ViewController
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "TaskEditViewController") as! TaskEditViewController
        
        // pass item to target ViewController
        newViewController.itemPassed = currentItem
        
        // change views
        self.present(newViewController, animated: true, completion: nil)
    }
    
    // determine background color based on priority
    func determineColor(importance: Int) -> UIColor {
        if importance == -1 {
            return UIColor.white
        }
        else if importance == 0 {
            return UIColor.yellow.withAlphaComponent(0.2)
        }
        else if importance == 1 {
            return UIColor.orange.withAlphaComponent(0.2)
        }
        else {
            return UIColor.red.withAlphaComponent(0.2)
        }
    }
    
    // determine time between a date and the present
    func determineDistanceInDays(itemDate: Date) -> Double {
        return itemDate.timeIntervalSinceNow/60/60/24
    }
    
    // change query key when search field is modified
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        queryItems()
    }
    
    // close searchbar when search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    // remove status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
