//
//  SelectViewController.swift
//  NutriSafe
//
//  Created by Geon Yoo on 11/16/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit


class SelectViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Nutrisafe will be using Collectionview to show / add / edit user profiles
    @IBOutlet weak var newProfButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var localStorage: [String: [[String]]] = [:] // stored profiles in UserDefaults
    var addVC: addProfileViewController?
    var theProfile: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var profiles: [Profile] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        addVC = self.storyboard?.instantiateViewController(withIdentifier: "addProfileViewController") as? addProfileViewController
        collectionView.dataSource = self
        collectionView.delegate = self
        loadDataBase()
        if(profiles.isEmpty) {
             self.navigationController?.pushViewController(addVC!, animated: true)
        }
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles.count
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        self.navigationController?.pushViewController(addVC!, animated: true)
    }
    
    // This function will load profile views
    // 1) if there is an existing profile stored
    // 2) else prompt users to create a new profile


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ProfileCell
//        In case we use profile image
//        cell.ProfileImage =
        cell.userName.text = profiles[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _ = UserDefaults.standard.value(forKey: "localDatabase") as? [String: [[String]]]
        currentProfile.name = profiles[indexPath.row].name
        currentProfile.allergens = profiles[indexPath.row].allergens
        currentProfile.diet = profiles[indexPath.row].diet
        let someView = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        present(someView, animated: true, completion: nil)
        //print(savedDietInfo)
    }
    
    func loadDataBase() {
        if(UserDefaults.standard.object(forKey: "localDatabase") == nil){
            
            // do nothing
            
        }else{
            
            // Read from User Defaults
            let saved = UserDefaults.standard.value(forKey: "localDatabase") as? [String: [[String]]]
            //Optional(["David": [["Shrimp"], ["Vegan"]], "Peter": [["Chocolate"], ["Vegetarian"]]])
            
            if let sv = saved {
                for (key, values) in sv {
                    let dietDB = UserDefaults.standard.value(forKey: "dietDatabase") as? [String: [String]]
                    if let unWrappedDB = dietDB{
                        if let toAv = unWrappedDB[values[1][0]] {
                            let diet = Diet(name: values[1][0], toAvoid: toAv)
                            let tempProfile = Profile(name: key, allergens: values[0], diet: diet)
                            profiles.append(tempProfile)
                        }
                    }
                }
            }
            profiles.sort(by: {(prof: Profile, prof2: Profile) -> Bool in
                    return prof.name.lowercased() < prof2.name.lowercased()
            })
        }
    }
    
    func alert(title:String = "ALERT", message: String){
        print("alert")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}


