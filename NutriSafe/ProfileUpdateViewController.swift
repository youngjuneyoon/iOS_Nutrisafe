//
//  ProfileUpdateViewController.swift
//  NutriSafe
//
//  Created by Taehoon Bang on 11/16/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit

class ProfileUpdateViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var AllergiesTableView: UITableView!
    @IBOutlet weak var DietTableView: UITableView!
    
    @IBOutlet weak var newItem: UITextField!
    
    var listOfAllergies:[String] = []
    var listOfDiets:[String] = ["Vegan", "Lacto Vegetarian", "Vegetarian", "Pescatarian", "None"]
    var tempString:String?
    var localStorage:[String: [[String]]] = [:]
    var storageForDiet:String?
    
    
    @IBAction func updateButton(_ sender: Any) {
        let input = newItem.text!
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let removeWhiteSpace =  trimmedInput.replacingOccurrences(of: " ", with: "")
        let uncapitalized = removeWhiteSpace.lowercased()
        
        let currentUserAllergens = currentProfile.allergens
        
        var contains : Bool = false
        
        for eachAllergen in currentUserAllergens{
            
            if(uncapitalized == eachAllergen){
                contains = true
            }
        }
        
        if(contains == true){
            alertExistingItem()
        }else{
            self.listOfAllergies.append(input)
            updateUserAllergens(newAllergen: uncapitalized)
            self.AllergiesTableView.reloadData()
        }
    }
    
    @IBAction func updateDietButton(_ sender: Any) {
        if(storageForDiet == nil){
            alertDidNotSelectItem()
        }else{
            updateUserDiet()
            alertDidSelectItem()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tempString = newItem.text!
        
        
        // loadDiet()
        // loadAllergyDataBase()
        
        //이거 지워
        let key: String = "Peter"
        let dataInKey: [[Any]] = [["Chocolate"], ["vegetarian"]]
        
        let key2: String = "David"
        let dataInKey2: [[Any]] = [["Shrimp"], ["vegan"]]
        
        let dictionary = [
            key : dataInKey,
            key2: dataInKey2
        ]
        // Save to User Defaults
        UserDefaults.standard.set(dictionary, forKey: "localDatabase")
        
        updateGlobalProfile()
        
        AllergiesTableView.dataSource = self
        AllergiesTableView.delegate = self
        AllergiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "table1")
        
        DietTableView.dataSource = self
        DietTableView.delegate = self
        DietTableView.register(UITableViewCell.self, forCellReuseIdentifier: "table2")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberCount:Int?
        
        if tableView == self.AllergiesTableView {
            numberCount = listOfAllergies.count
        }
        
        if tableView == self.DietTableView {
            numberCount =  listOfDiets.count
        }
        return numberCount!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var myCell:UITableViewCell?
        
        if (tableView == self.AllergiesTableView){
            myCell = tableView.dequeueReusableCell(withIdentifier: "table1", for: indexPath)
            let firstTable = listOfAllergies[indexPath.row]
            myCell!.textLabel!.text = firstTable
            
        }
        
        if (tableView == self.DietTableView){
            myCell = tableView.dequeueReusableCell(withIdentifier: "table2", for: indexPath)
            let secondTable = listOfDiets[indexPath.row]
            myCell!.textLabel!.text = secondTable
        }
        return myCell!
    }
    
    //https://stackoverflow.com/questions/31182847/how-to-detect-tableview-cell-touched-or-clicked-in-swift
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.DietTableView){
            storageForDiet = listOfDiets[indexPath.row]
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (tableView == self.AllergiesTableView){
            if editingStyle == .delete {
                
                /* tempArray = UserDefaults.standard.array(forKey: "localDatabase") as! [String]
                 tempArray.remove(at: indexPath.row)
                 UserDefaults.standard.set(tempArray, forKey:"localDatabase")
                 */
                
                listOfAllergies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    //https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
    func alertExistingItem(){
        let alert = UIAlertController(title: "Alert", message: "This Item Already Exists", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertDidNotSelectItem(){
        let alert = UIAlertController(title: "Alert", message: "Please Choose a Diet", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertDidSelectItem(){
        let alert = UIAlertController(title: "Alert", message: "Diet Confirmed", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateUserAllergens(newAllergen: String){
        //read userdefault database
        localStorage = UserDefaults.standard.value(forKey: "localDatabase") as! [String: [[String]]]
        //this is accessing the list of allergies specific person has and then appending
        localStorage[currentProfile.name]![0].append(newAllergen)
        //store again to the database
        UserDefaults.standard.set(localStorage, forKey: "localDatabase")
        //update the currentProfile global variable to easy retrieval of data
        currentProfile.allergens = localStorage[currentProfile.name]![0]
        /*var listOfStringValue = localStorage[currentProfile.name]
         var specific = listOfStringValue?[0]
         specific?.append(newAllergen)*/
    }
    
    func updateUserDiet(){
        //read userdefault database
        localStorage = UserDefaults.standard.value(forKey: "localDatabase") as! [String: [[String]]]
        //this is accessing the list of allergies specific person has and then appending
        localStorage[currentProfile.name]![1][0] = (storageForDiet!)
        //store again to the database
        UserDefaults.standard.set(localStorage, forKey: "localDatabase")
        //update the currentProfile global variable to easy retrieval of data
        currentProfile.diet?.name = storageForDiet!
    }
    
    func updateGlobalProfile(){
       /* localStorage = UserDefaults.standard.value(forKey: "localDatabase") as! [String: [[String]]] */
        //이거 지워
        // Read from User Defaults
        let saved = UserDefaults.standard.value(forKey: "localDatabase") as? [String: [[String]]]
        currentProfile.name = "Peter"
        currentProfile.allergens = saved![currentProfile.name]![0]
        currentProfile.diet?.name = saved![currentProfile.name]![1][0]
        listOfAllergies = currentProfile.allergens 
    }
}
