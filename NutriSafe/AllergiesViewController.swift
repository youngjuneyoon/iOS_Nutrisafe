//
//  AllergiesViewController.swift
//  NutriSafe
//
//  Created by Geon Yoo on 12/1/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit
var tempAllergens : [String] = []

class AllergiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textOutlet: UITextField!
    @IBOutlet weak var savebutton: UIButton!
    
    var allergiesData: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.allowsSelectionDuringEditing = true
        allergiesData = ["none", "nuts", "treenuts", "walnuts", "wheat", "buckwheat", "milk", "gluten", "soy", "peanuts", "egg"] // example
        for all in tempAllergens {
            if !allergiesData.contains(all){
                allergiesData.append(all)
            }
        }
        tableView.keyboardDismissMode = .onDrag
        tableView.reloadData()
        setSelected()
        setToolBar()
        // Do any additional setup after loading the view.
    }
    
    func setToolBar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
        ]
        textOutlet.inputAccessoryView = toolbar
    }
    
    @objc func doneAction(){
        self.textOutlet.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allergiesData.count
    }

    @IBAction func addAction(_ sender: Any) {
        if textOutlet.text! == "" {
            // do nothing
        }
        else if tempAllergens.contains(textOutlet.text!) || allergiesData.contains(textOutlet.text!){
            textOutlet.text!.removeAll()
        }
        else{
            allergiesData.append(textOutlet.text!)
            tempAllergens.append(textOutlet.text!)
            tableView.reloadData()
            setSelected()
            textOutlet.text!.removeAll()
            print(tempAllergens)
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.indexPathsForSelectedRows //calls array of selected items
        let cell = tableView.cellForRow(at: indexPath)
        var containsItem:Bool = false
        for i in 0..<tempAllergens.count{
            if tempAllergens[i] == (cell?.textLabel?.text)!{
                containsItem = true
            }
        }
        
        if(!containsItem){
            tempAllergens.append((cell?.textLabel?.text)!)
        }
        print(tempAllergens)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        for (index, al) in tempAllergens.enumerated() {
            if(al == cell?.textLabel!.text) {
                tempAllergens.remove(at: index)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbCell")!
        cell.textLabel!.text = allergiesData[indexPath.row]
        return cell
    }
    
    func setSelected(){
        print(tempAllergens)
        for (index, al) in allergiesData.enumerated() {
            print(al)
            if(tempAllergens.contains(al)){
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.bottom)
            }
        }
    }
    
    func alert(title:String = "ALERT", message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
