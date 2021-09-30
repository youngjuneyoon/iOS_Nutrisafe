//
//  SecondViewController.swift
//  NutriSafe
//
//  Created by Yang on 11/12/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit

class SavedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var savedFoods = [Food]()
    var foodIds = [String]()
    var currentImage: UIImage = UIImage(named: "noImage")!
    @IBOutlet weak var savedList: UITableView!
    var detailedVC: DetailedViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        detailedVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailedViewController") as? DetailedViewController
        setupTableView()
        navigationItem.title = "Saved Foods for \(currentProfile.name)"
    }
    
    func loadFromUserDefaults(){
        let saved = UserDefaults.standard.value(forKey: "foodDatabase") as? [String: [String: [String]]]
        if let sv = saved {
            if let svUser = sv[currentProfile.name] {
                if(savedFoods.count == svUser.count){
                    print("no need to load userdefaults")
                    return
                }
                savedFoods = []
                print("WOW THIS IS FROM USERDEFAULTS")
                for (id, values) in svUser {
                    print(values)
                    var tmpFood = Food(name: values[1], photoUrl: values[4], nix_item_id: values[0], nf_ingredient_statement: values[5])
                    tmpFood.nf_calories = Float(values[2])
                    tmpFood.serving_unit = values[3]
                    savedFoods.append(tmpFood)
                    foodIds.append(id)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadFromUserDefaults()
        savedList.reloadData()
    }
    
    func setupTableView(){
        savedList.delegate = self
        savedList.dataSource = self
        savedList.register(UITableViewCell.self, forCellReuseIdentifier: "listItem")
    }
    
    func addFood(food: Food) -> Bool{
        print("add food")
        if let id = food.nix_item_id {
            if(foodIds.contains(id)){
                return false
            } else {
                savedFoods.append(food)
                foodIds.append(id)
                saveToDB(foods: savedFoods)
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("reload data")
        return savedFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "listItem")
        cell.textLabel!.text = savedFoods[indexPath.row].food_name
        if (savedFoods[indexPath.row].photo?.thumb != nil) {
            cell.imageView!.image = UIImage(contentsOfFile: savedFoods[indexPath.row].photo!.thumb)
        }
        else {
            cell.imageView?.image = UIImage(named: "noPhoto")
        }
        return cell
    }
    //Select
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("in did select row")
        detailedVC?.setData(food: savedFoods[indexPath.row])
        //present(detailedVC!, animated: true)
        self.navigationController?.pushViewController(self.detailedVC!, animated:true)
    }
    //Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedFoods.remove(at: indexPath.row)
            foodIds.remove(at: indexPath.row)
            savedList.reloadData()
            saveToDB(foods: savedFoods)
        }
    }
    
    func saveToDB(foods: [Food]){
        print(savedFoods.count)
        if(UserDefaults.standard.object(forKey: "foodDatabase") == nil){
            let placeHolder: [String:[String:[String]]] = [currentProfile.name:[:]]
            UserDefaults.standard.set(placeHolder, forKey: "foodDatabase")
        }
        
        var foodDictionary: [String: [String]] = [:]
        for fd in foods {
            if(fd.nix_item_id == nil){
                return
            }
            let foodId = fd.nix_item_id!
            var foodDetail: [String] = []
            foodDetail.append(foodId)
            foodDetail.append(fd.food_name)
            if let cal = fd.nf_calories {
                foodDetail.append(String(cal))
            } else {
                foodDetail.append("N/A")
            }
            if let su = fd.serving_unit {
                foodDetail.append(String(su))
            } else {
                foodDetail.append("N/A")
            }
            foodDetail.append(fd.photo?.thumb ?? "N/A")
            foodDetail.append(fd.nf_ingredient_statement ?? "N/A")
            foodDictionary[String(foodId)] = foodDetail
        }
        
        let key: String = currentProfile.name
        let finalFoodDictionary = [
            key : foodDictionary
        ]
        // Save to User Defaults
        UserDefaults.standard.set(finalFoodDictionary, forKey: "foodDatabase")
    }
    
    func alert(title: String = "ALERT", message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    //https://sweettutos.com/2016/01/31/how-to-programmatically-save-and-load-uiimage-files-in-the-document-directory-with-swift/
    //https://iswiftdeveloper.wordpress.com/2018/01/30/save-and-get-image-from-document-directory-in-swift/
    
    //https://iswiftdeveloper.wordpress.com/2018/01/30/save-and-get-image-from-document-directory-in-swift/
    /*
     func createDirectory(){
     let fileManager = FileManager.default
     let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("images")
     if fileManager.fileExists(atPath: paths){
     do {
     try fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
     print("it was made")
     } catch {
     print("didn't work")
     }
     }else{
     print("didn't create new one")
     }
     }
     //https://iswiftdeveloper.wordpress.com/2018/01/30/save-and-get-image-from-document-directory-in-swift/
     func getDirectoryPath() -> String {
     let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
     let documentsDirectory = paths[0]
     print(paths)
     return documentsDirectory
     }
     //https://stackoverflow.com/questions/51531165/uiimagejpegrepresentation-has-been-replaced-by-instance-method-uiimage-jpegdata
     //https://iswiftdeveloper.wordpress.com/2018/01/30/save-and-get-image-from-document-directory-in-swift/
     func saveImageToDocumentDirectory( name: String){
     var imageData = UIImage(named: "noImage")?.jpegData(compressionQuality: 0.5)
     let fileManager = FileManager.default
     let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
     //        if let image2 = currentImage {
     imageData = currentImage.jpegData(compressionQuality: 0.5)
     print("real image saved")
     //        }
     //        else {
     //            imageData = UIImage(named: "noImage")?.jpegData(compressionQuality: 0.5)
     //            print("non real image saved")
     //        }
     fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
     print("added image" + name + "to path" + paths)
     }
     //https://iswiftdeveloper.wordpress.com/2018/01/30/save-and-get-image-from-document-directory-in-swift/
     //should get getting image
     func getImage(imageName : String)-> UIImage {
     let fileManager = FileManager.default
     let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
     print("this is imagepath" + imagePath)
     if fileManager.fileExists(atPath: imagePath){
     print("return real image")
     return UIImage(contentsOfFile: imagePath)!
     }
     else {
     print("found nil")
     return UIImage(named: "noImage")!
     }
     }
     */
}
