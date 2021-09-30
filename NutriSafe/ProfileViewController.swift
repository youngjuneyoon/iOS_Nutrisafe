//
//  ProfileViewController.swift
//  NutriSafe
//
//  Created by Yang on 11/13/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var allergiesTableView: UITableView!
    @IBOutlet weak var dietInfo: UILabel!
    
    var addProfileVC: addProfileViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        addProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "addProfileViewController") as? addProfileViewController
        // Do any additional setup after loading the view.
        allergiesTableView.dataSource = self
        allergiesTableView.delegate = self
        allergiesTableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameLabel.text = currentProfile.name
        dietInfo.text = currentProfile.diet?.name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentProfile.allergens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = allergiesTableView.dequeueReusableCell(withIdentifier: "EditProfileCell")!
        myCell.textLabel!.text = currentProfile.allergens[indexPath.row]
        return myCell
    }
    
    @IBAction func editProfileOnClicked(_ sender: Any) {
        addProfileVC?.setDataFromEdit(name: currentProfile.name, allergens: currentProfile.allergens, dietName: currentProfile.diet?.name)
        self.navigationController?.pushViewController(addProfileVC!, animated: true)
    }
    
    @IBAction func deleteProfileButton(_ sender: Any) {
        
        var localStorage = UserDefaults.standard.value(forKey: "localDatabase") as? [String: [[String]]]
        //localStorage.removeValue(forKey: currentProfile.name)
        if let data = localStorage {
            if(data[currentProfile.name] != nil){
                localStorage?.removeValue(forKey: currentProfile.name)
            }
        }
        
        //store again to the database
        UserDefaults.standard.set(localStorage, forKey: "localDatabase")
        
        //update the currentProfile global variable to easy retrieval of data
        currentProfile.allergens = []
        currentProfile.name = ""
        currentProfile.diet = nil
        
        let someView = storyboard?.instantiateViewController(withIdentifier: "FrontNavigationController") as! UINavigationController

        present(someView, animated: true, completion: nil)
        
    }

    @IBAction func changeProfileButton(_ sender: Any) {
        
        let someView = storyboard?.instantiateViewController(withIdentifier: "FrontNavigationController") as! UINavigationController
        present(someView, animated: true, completion: nil)
        
    }
}
