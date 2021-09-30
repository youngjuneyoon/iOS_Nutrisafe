//
//  FirstViewController.swift
//  NutriSafe
//
//  Created by Yang on 11/12/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import UIKit
import BarcodeScanner
class HomeViewController: UIViewController, BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate, UISearchBarDelegate {
    
    let barcodeURLPrefix = "https://trackapi.nutritionix.com/v2/search/item?upc="
    let queryURLPrefix = "https://trackapi.nutritionix.com/v2/search/instant?query="
    var foods: Foods = Foods()
    var searchedFoods: SearchedFoods = SearchedFoods()
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchedResponseVC: SearchResponseViewController?
    var detailedVC: DetailedViewController?
    //var navigationController: UINavigationController?
    var savedVC: SavedViewController?
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchedResponseVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchResponseViewController") as? SearchResponseViewController
        detailedVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailedViewController") as? DetailedViewController
        let navVC = self.tabBarController?.viewControllers?[1] as? UINavigationController
        savedVC = navVC?.viewControllers[0] as? SavedViewController
        print("savedVC null: \(savedVC.debugDescription))")
        searchBar.delegate = self
        scanButton.layer.cornerRadius = 100
        scanButton.clipsToBounds = true
        scanButton.layer.shadowRadius = 1.0
        scanButton.layer.shadowColor = UIColor.black.cgColor
//        let someView = storyboard?.instantiateViewController(withIdentifier: "SelectViewController") as! SelectViewController
//        present(someView, animated: true, completion: nil)
        endSpinner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameLabel.text = currentProfile.name
    }

    func parseIngredients(input: String) -> [String] {
        var filtered = input.replacingOccurrences(of: ", ", with: ",")
        filtered = filtered.replacingOccurrences(of: ".", with: "")
        filtered = filtered.lowercased()
        let list = filtered.components(separatedBy: ",")
        return list
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        savedVC?.savedFoods = []
        savedVC?.foodIds = []
        let searchText = searchBar.text!
        if(searchBar.text?.count != 0){
            DispatchQueue.global(qos: .userInitiated).async {
                var query = searchText.lowercased()
                query = query.filter(" 0123456789abcdefghijklmnopqrstuvwxyz".contains)
                query = query.replacingOccurrences(of: " ", with: "%20")
                self.getFoodsFromSearch(query: query)
            }
        }
    }
    
    @IBAction func scanButtonOnClick(_ sender: Any) {
        let scannerController = BarcodeScannerViewController()
        scannerController.codeDelegate = self
        scannerController.errorDelegate = self
        scannerController.dismissalDelegate = self
        present(scannerController, animated: true, completion: nil)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        if(code.count != 12){
            alert(title: "Error", message: "not a barcode")
            return
        }
        getFoodFromBarCode(upc: code)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func getFoodsFromSearch(query: String){
        let url = URL(string: queryURLPrefix+query)!
        var myRequest = URLRequest(url: url)
        myRequest.httpMethod = "GET"
        myRequest.addValue(xappid, forHTTPHeaderField: "x-app-id")
        myRequest.addValue(xappkey, forHTTPHeaderField: "x-app-key")
        myRequest.addValue(xremoteuserid, forHTTPHeaderField: "x-remote-user-id")
        let session = URLSession.shared
        let mData = session.dataTask(with: myRequest as URLRequest) { (data, response, error) -> Void in
            if let res = response as? HTTPURLResponse {
                //success
                if res.statusCode == 200 {
                    self.searchedFoods = try! JSONDecoder().decode(SearchedFoods.self, from: data!)
                    DispatchQueue.main.async {
                        self.searchBar.endEditing(true)
                        self.navigationController?.pushViewController(self.searchedResponseVC!, animated:true)
                        self.toSearchedView()
                    }
                } else {
                    self.alert(title: "Error", message: String(describing: error))
                }
            }else{
                print("Error: \(String(describing: error))")
            }
        }
        mData.resume()
    }
    
    func getFoodFromBarCode(upc: String){
        let url = URL(string: barcodeURLPrefix+upc)!
        var myRequest = URLRequest(url: url)
        myRequest.httpMethod = "GET"
        myRequest.addValue(xappid, forHTTPHeaderField: "x-app-id")
        myRequest.addValue(xappkey, forHTTPHeaderField: "x-app-key")
        myRequest.addValue(xremoteuserid, forHTTPHeaderField: "x-remote-user-id")
        let session = URLSession.shared
        let mData = session.dataTask(with: myRequest as URLRequest) { (data, response, error) -> Void in
            if let res = response as? HTTPURLResponse {
                //200 means "Success"
                if res.statusCode == 200 {
                    self.foods = try! JSONDecoder().decode(Foods.self, from: data!)
                    if self.foods.foods.count > 0, let food = self.foods.foods[0] {
                        DispatchQueue.main.async {
                            self.toDetailedView(food: food)
                        }
                    }
                } else {
                    
                }
            } else {
                print("Error: \(String(describing: error))")
            }
        }
        mData.resume()
    }
    
    func alert(title:String = "ALERT", message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func toSearchedView(){
        self.searchedResponseVC?.searchedFoods = self.searchedFoods.branded as! [Food]
        self.searchedResponseVC?.imageCache = []
        self.searchedResponseVC?.collectionView?.reloadData()
        self.searchedResponseVC?.ifStartSpin = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.searchedResponseVC?.cacheImages()
            DispatchQueue.main.async {
                self.searchedResponseVC?.endSpinner()
                self.searchedResponseVC?.ifStartSpin = false
                self.searchedResponseVC?.collectionView?.reloadData()
            }
        }
    }
    
    func toDetailedView(food: Food){
        detailedVC?.setData(food: food)
        detailedVC?.loadLabels()
        self.navigationController?.pushViewController(self.detailedVC!, animated:true)
    }
    
    func startSpinner(){
        spinner.isHidden = false
        spinner.startAnimating()
        spinner.frame = self.view.frame
        spinner.style = UIActivityIndicatorView.Style.whiteLarge
        spinner.color = UIColor.black
    }
    
    func endSpinner(){
        spinner.isHidden = true
        spinner.stopAnimating()
    }
}

