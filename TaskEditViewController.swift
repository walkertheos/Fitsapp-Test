//
//  NewItemViewController.swift
//  Fitsapp Test
//
//  Created by Theodore S. Walker on 3/18/17.
//  Copyright © 2017 TheoWalker. All rights reserved.
//

import UIKit
import RealmSwift

class TaskEditViewController: UIViewController, UITextFieldDelegate {
    
    // storage for editing mode
    var itemPassed = Item()
    
    override func viewDidLoad() {
        
        // initial setup
        super.viewDidLoad()
        self.newTaskName.delegate = self
        
        // transfer values of task into local fields
        edit()
    }
    
    // outlets for various view elements
    @IBOutlet weak var newTaskName: UITextField!
    @IBOutlet weak var newTaskImportance: UISegmentedControl!
    @IBOutlet weak var newTaskDate: UIDatePicker!
    @IBOutlet weak var titleLabel: UILabel!
    
    // save new task
    @IBAction func newTaskSave() {
        
        // define new Item object
        let item = Item()
        item.name = newTaskName.text!
        item.importance = newTaskImportance.selectedSegmentIndex
        item.date = newTaskDate.date
        
        // add item to Realm and delete old item (if it exists)
        let realm = try! Realm()
        try! realm.write {
            realm.add(item)
            if itemPassed.name != "" || itemPassed.importance != -1 {
                realm.delete(itemPassed)
            }
        }
    }

    // dismiss keyboard upon touch outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // dismiss keyboard when return key is hit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newTaskName.resignFirstResponder()
        return(true)
    }
    
    // retain values of passed task
    func edit() {
        newTaskName.text = itemPassed.name
        newTaskImportance.selectedSegmentIndex = itemPassed.importance
        newTaskDate.date = itemPassed.date
    }
    
    // remove status bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
