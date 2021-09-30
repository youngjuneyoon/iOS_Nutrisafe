//
//  addProfileViewController.swift
//  NutriSafe
//
//  Created by Geon Yoo on 11/18/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit


var globalNameArray: [String] = []

class addProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // NutriSafe will use UserDefaults to store user profiles
    // And from this viewController, users can add, edit and delete profiles
    
    var savedProfiles: [String: [[String]]] = [:] // entire database that stores all the profiles... Kon...Peter...
    
    var localStorage: [String: [[String]]] = [:] // current profile
    
    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var welcomeImage: UIImageView!
    
    var dietData: [String] = [String]()
    
    var theUser : String = ""
    var theDiet: String = ""
    var isEdit = false
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var allergiesButton: UIButton!
    
    var allergiesVC: AllergiesViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        allergiesVC = self.storyboard?.instantiateViewController(withIdentifier: "AllergiesViewController") as? AllergiesViewController
        loadDiet()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.userNameInput.delegate = self
        dietData = ["---Please Select---","Vegan", "Vegetarian", "Lacto Vegetarian", "Pescatarian", "None"]
        updateLabel()
        setToolBar()
    }
    
    func setToolBar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
        ]
        userNameInput.inputAccessoryView = toolbar
    }
    
    @objc func doneAction(){
        self.userNameInput.resignFirstResponder()
    }
    
    func setDataFromEdit(name: String, allergens: [String], dietName: String?){
        isEdit = true
        theDiet = dietName ?? "None"
        theUser = name
        tempAllergens = allergens
    }
    
    func updateLabel(){
        if(isEdit){
            userNameInput.isEnabled = false
            topTitle.text = "Edit Profile"
            welcomeImage.isHidden = true
        } else {
            tempAllergens = []
        }
        userNameInput.text = theUser
        for (i, data) in dietData.enumerated() {
            if(data == theDiet){
                pickerView.selectRow(i, inComponent: 0, animated: true)
                return
            }
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        // save all the datas in the userdefaults
        // prompt the barcode view -> storyboard
        theUser = (userNameInput.text!)
        theUser = theUser.filter(" 0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains)
        theUser = theUser.replacingOccurrences(of: " ", with: "")
        
        if(theUser == "" || tempAllergens.isEmpty || theDiet == "---Please Select---" || theDiet == ""){
            alertExistingItem()
        } else {
            if(UserDefaults.standard.object(forKey: "localDatabase") == nil){
                //make new database, and insert
                let dictionary = [String:[[String]]]()
                //Save to UserDefault
                UserDefaults.standard.set(dictionary, forKey: "localDatabase")
            }
            //Look for key and compare, if exist then alert user that account already exists
                //else add new users
            
            savedProfiles = UserDefaults.standard.dictionary(forKey: "localDatabase") as! [String: [[String]]]
            
            if savedProfiles.keys.contains(theUser) && !isEdit{
                print(theUser)
                alertExistingUserName()
            } else {
                let key: String = theUser
                let dataInKey: [[String]] = [tempAllergens, [theDiet]]
                //Save to UserDefault
                savedProfiles[key] = dataInKey
                print(savedProfiles)
                UserDefaults.standard.set(savedProfiles, forKey: "localDatabase")
                currentProfile.name = theUser
                currentProfile.allergens = tempAllergens
                let savedDietInfo = UserDefaults.standard.dictionary(forKey: "dietDatabase") as! [String: [String]]
                let dietValue = savedDietInfo[theDiet]
                print(savedDietInfo)
                let tempDiet: Diet = Diet(name: theDiet, toAvoid: dietValue!)
                currentProfile.diet = tempDiet

                let someView = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                present(someView, animated: true, completion: nil)
            }

        }
        
    }
    
    @IBAction func allergyOnClick(_ sender: Any) { self.navigationController?.pushViewController(allergiesVC!, animated:true)
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        globalName = UserDefaults.standard.string(forKey: "tempName") as! String
//        globalName.append(contentsOf: userNameInput.text!)
//        print(globalName)
//    }

  /*  @IBAction func textChanged(_ sender: Any) {
        globalName = userNameInput.text!
        globalName = UserDefaults.standard.string(forKey: "tempName") as! String
        globalName.append(contentsOf: userNameInput.text!)
        print(globalName)
    }*/
    
//    @IBAction func textChanged(_ sender: Any) {
//        globalName = userNameInput.text!
//        print(globalName)
//    }
//

    func alertExistingUserName() {
        let alert = UIAlertController(title: "Alert", message: "You already have the username", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertExistingItem(){
        let alert = UIAlertController(title: "Alert", message: "You have Empty Field", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadDiet(){
        if(UserDefaults.standard.object(forKey: "dietDatabase") == nil){
            let keyVegan: String = "Vegan"
            let dataInKeyVegan: [String] = ["beef", "lamb", "pork", "veal", "horse", "meat", "chicken", "turkey", "goose", "duck", "fish", "anchovies", "shrimp", "squid", "scallops", "calamari", "mussels", "crab", "lobster", "fish sauce", "milk", "yogurt", "cheese", "butter", "cream", "ice cream", "ostrich", "honey", "jelly", "eggs", "dairy", "gelatin"]
            
            let keyVegetarian: String = "Vegetarian"
            let dataInKeyVegetarian: [String] = ["beef", "lamb", "pork", "veal", "horse", "meat", "chicken", "turkey", "goose", "duck", "fish", "anchovies", "shrimp", "squid", "scallops", "calamari", "mussels", "crab", "lobster", "fish sauce", "ostrich", "gelatin"]
            
            let keyLactoVegetarian: String = "Lacto Vegetarian"
            let dataInKeyLactoVegetarian: [String] = ["beef", "lamb", "pork", "veal", "horse", "meat", "chicken", "turkey", "goose", "duck", "fish", "anchovies", "shrimp", "squid", "scallops", "calamari", "mussels", "crab", "lobster", "fish sauce", "ostrich", "eggs", "gelatin"]
            
            let keyPescatarian: String = "Pescatarian"
            let dataInKeyPescatarian: [String] = ["beef", "lamb", "pork", "veal", "horse", "meat", "chicken", "turkey", "goose", "duck", "ostrich"]
            
            let keyNone: String = "None"
            let dataInKeyNone: [String] = []
            
            let dictionaryOfDiets = [
                keyVegan : dataInKeyVegan,
                keyVegetarian: dataInKeyVegetarian,
                keyLactoVegetarian : dataInKeyLactoVegetarian,
                keyPescatarian: dataInKeyPescatarian,
                keyNone: dataInKeyNone
            ]
            
            //save
            UserDefaults.standard.set(dictionaryOfDiets, forKey: "dietDatabase")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dietData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dietData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        theDiet = dietData[row] // add picker data to local variable theDiet(String)
        print(dietData[row])
    }

   
        // adding profiles each time we click add button --> No... call new controller
        // this is for in the detailed view controller
    
//    @IBAction func allergiesAction(_ sender: Any) {
//        let tableVC = storyboard?.instantiateViewController(withIdentifier: "AllergiesViewController") as! AllergiesViewController
//        tableVC.view.backgroundColor = UIColor.white
//        
//    }
    
    
}
