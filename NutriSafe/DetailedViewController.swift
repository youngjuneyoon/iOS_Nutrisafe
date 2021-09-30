//
//  DetailedViewController.swift
//  NutriSafe
//
//  Created by Lucy Liu on 11/14/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {
    
    var allergens: [String] = []
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var allergenLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var servingSizeLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var isSafeLabel: UILabel!
    @IBOutlet weak var fitsDietLabel: UILabel!
    
    var name: String! = "Name"
    var ingredientStr: String = "Ingredients: "
    var calories: Float = 0.0
    var image: UIImage = UIImage(named: "noImage")!
    var servingSize: String = "N/A"
    var isSafe: Bool = false
    var fitsDiet: Bool = false
    var thisFood: Food?
    var savedVC: SavedViewController?
    var notSafeIngs = ""
    var notDietIngs = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let navVC = self.tabBarController?.viewControllers?[1] as? UINavigationController
        savedVC = navVC?.viewControllers[0] as? SavedViewController
        print("savedVC null: \(savedVC.debugDescription))")
        loadLabels()
    }
    
    @IBAction func addShoppingList(_ sender: Any) {
        if let fd = thisFood {
            if let safeSavedVC = savedVC {
                if (safeSavedVC.addFood(food: fd)) {
                    alert(title: "SUCCESS", message: "Saved to Shopping Cart")
                } else {
                    alert(title: "FAIL", message: "item already exists or invalid")
                }
            }
        }
    }
    
    func alert(title:String = "ALERT", message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func ingredientButton(_ sender: Any) {
        alert(title: "Ingredients", message: thisFood?.nf_ingredient_statement ?? "N/A")
    }
    
    @IBAction func safeToEatButton(_ sender: Any) {
        alert(title: "Contains", message: notSafeIngs)
    }
    
    @IBAction func fitsYourDietButton(_ sender: Any) {
        alert(title: "Contains", message: notDietIngs)
    }
    
    func setData(food: Food, image: UIImage? = nil){
        thisFood = food
        self.name = food.food_name
        self.ingredientStr = "Ingredients: \(food.nf_ingredient_statement ?? "N/A")"
        self.calories = food.nf_calories ?? 0
        self.servingSize = (food.serving_unit ?? "N/A")
        match(food: food, profile: currentProfile)
        if let img = image {
            self.image = img
            imageView?.image = img
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                if let foodurl = food.photo?.thumb {
                    let imageURL = URL(string: foodurl)
                    if let url = imageURL {
                        let data = try? Data(contentsOf: url)
                        if let dt = data {
                            if let finalImage = UIImage(data: dt) {
                                self.image = finalImage
                                DispatchQueue.main.async {
                                    self.imageView?.image = self.image
                                }
                            }
                        }
                    }
                }
            }
        }
        loadLabels()
    }
    
    
    func loadLabels(){
        nameLabel?.text = name
        caloriesLabel?.text = "Calories: \(String(calories)) per Serving"
        ingredientsLabel?.text = ingredientStr
        imageView?.image = image
        servingSizeLabel?.text = "Serving Size: \(servingSize)"
        var safeEmo = isSafe ? "✅" : "❌"
        var dietEmo = fitsDiet ? "✅" : "❌"
        if thisFood == nil || thisFood?.nf_ingredient_statement == nil || thisFood?.nf_ingredient_statement == "N/A" {
            safeEmo = "❓"
            dietEmo = "❓"
        }
        isSafeLabel?.text = "Safe to Eat       " + safeEmo
        fitsDietLabel?.text = "Fits Your Diet " + dietEmo
        
    }
    
    func match(food: Food, profile: Profile) {
        if let ingStr = food.nf_ingredient_statement {
            let ingredients = parseIngredients(input: ingStr)
            self.isSafe = isSafe(ingredients: ingredients, toAvoid: profile.allergens)
            self.fitsDiet = isDiet(ingredients: ingredients, toAvoid: profile.diet?.toAvoid ?? [])
        }
    }
    
    func isSafe(ingredients: [String], toAvoid: [String]) -> Bool {
        notSafeIngs = ""
        print(ingredients)
        print(toAvoid)
        var ans = true
        for ing in ingredients {
            for toAv in toAvoid {
                if(ing.contains(toAv)){
                    notSafeIngs.append("\(ing) ")
                    ans = false
                }
            }
        }
        return ans
    }
    
    func isDiet(ingredients: [String], toAvoid: [String]) -> Bool {
        notDietIngs = ""
        var ans = true
        for ing in ingredients {
            for toAv in toAvoid {
                if(ing.contains(toAv)){
                    notDietIngs.append("\(ing), ")
                    ans = false
                }
            }
        }
        return ans
    }
    
    func parseIngredients(input: String) -> [String] {
        var filtered = input.replacingOccurrences(of: ", ", with: ",")
        filtered = filtered.replacingOccurrences(of: ".", with: "")
        filtered = filtered.lowercased()
        let list = filtered.components(separatedBy: ",")
        return list
    }
    
}
