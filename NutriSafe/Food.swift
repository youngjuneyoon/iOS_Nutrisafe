struct SearchedFoods: Decodable {
    var common: [Food?] = []
    var branded: [Food?] = []
}
struct Foods: Decodable {
    var foods: [Food?] = []
}
struct Food: Decodable {
    var food_name : String = "unnamed"
    var brand_name : String? = nil
    var serving_qty : Float? = nil
    var serving_unit : String? = nil
    var serving_weight_grams : Float? = nil
    var nf_calories : Float? = nil
    var nf_total_fat : Float? = nil
    var nf_saturated_fat : Float? = nil
    var nf_cholesterol : Float? = nil
    var nf_sodium : Float? = nil
    var nf_total_carbohydrate: Float? = nil
    var nf_dietary_fiber: Float? = nil
    var nf_sugars : Float? = nil
    var nf_protein: Float? = nil
    var nf_potassium: Float? = nil
    var nf_p: Float? = nil
    var nix_brand_name: String? = nil
    var nix_item_name: String? = nil
    var nix_item_id: String? = nil
    var source: Int? = nil
    var photo: Photo? = nil
    var nf_ingredient_statement: String? = nil
    init(name: String, photoUrl: String?, nix_item_id: String, nf_ingredient_statement: String?){
        food_name = name
        if let url = photoUrl {
            photo = Photo(thumb: url, highres: "null", is_user_uploaded: false)
        }
        self.nix_item_id = nix_item_id
        self.nf_ingredient_statement = nf_ingredient_statement
    }
}
