import UIKit

class SearchResponseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    var searchedFoods: [Food] = []
    var newArray: [UIImage] = []
    var finalNewArray: [UIImage] = []
    var imageCache: [UIImage] = []
    var detailedVC: DetailedViewController?
    var itemURLPrefix = "https://trackapi.nutritionix.com/v2/search/item?nix_item_id="
    var ifStartSpin = false;
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        detailedVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailedViewController") as? DetailedViewController
        setupCollectionView()
        collectionView.reloadData()
        if(ifStartSpin){
            startSpinner()
        } else {
            endSpinner()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(ifStartSpin){
            startSpinner()
        } else {
            endSpinner()
        }
        collectionView.reloadData()
    }
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "food", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        let label = cell.viewWithTag(2) as! UILabel
        label.textColor = .white
        label.textAlignment = .center
        if(imageCache.count == searchedFoods.count && indexPath.row < imageCache.count){
            imageView.image = imageCache[indexPath.row]
        } else {
            imageView.image = UIImage (named: "noImage")!
        }
        let currentFood = searchedFoods[indexPath.row]
        label.text = currentFood.food_name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clickedFood = searchedFoods[indexPath.row]
        //if already cached this food's ingredient information before
        if let ing = clickedFood.nf_ingredient_statement {
            print(ing)
            if(indexPath.row < self.imageCache.count){
                self.toDetailedView(food: self.searchedFoods[indexPath.row], image: self.imageCache[indexPath.row])
            } else {
                self.toDetailedView(food: self.searchedFoods[indexPath.row], image: nil)
            }
        } else {
            if let id = clickedFood.nix_item_id {
                let url = URL(string: itemURLPrefix + id)!
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
                            let foods = try! JSONDecoder().decode(Foods.self, from: data!)
                            if foods.foods.count > 0, let food = foods.foods[0] {
                                self.searchedFoods[indexPath.row] = food
                                DispatchQueue.main.async {
                                    if(indexPath.row < self.imageCache.count){
                                        self.toDetailedView(food: self.searchedFoods[indexPath.row], image: self.imageCache[indexPath.row])
                                    } else {
                                        self.toDetailedView(food: self.searchedFoods[indexPath.row], image: nil)
                                    }
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
        }
    }
    
    func toDetailedView(food: Food, image: UIImage?){
        detailedVC?.setData(food: food, image: image)
        self.navigationController?.pushViewController(self.detailedVC!, animated:true)
    }
    
    func cacheImages(){
        newArray = []
        for food in searchedFoods {
            if let foodurl = food.photo?.thumb {
                let imageURL = URL(string: foodurl)
                if let url = imageURL {
                    let data = try? Data(contentsOf: url)
                    if let finalImage = UIImage(data: data!) {
                        newArray.append(finalImage)
                    }
                    else {
                        newArray.append(UIImage (named: "noImage")!)
                    }
                }
            }
        }
        imageCache = newArray
        print("Cache Done")
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func startSpinner(){
        spinner?.isHidden = false
        spinner?.startAnimating()
        spinner?.frame = self.view.frame
        spinner?.style = UIActivityIndicatorView.Style.whiteLarge
        spinner?.color = UIColor.black
    }
    
    func endSpinner(){
        spinner.isHidden = true
        spinner.stopAnimating()
    }
    
}
