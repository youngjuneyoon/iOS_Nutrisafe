//
//  Photo.swift
//  NutriSafe
//
//  Created by Yang on 11/16/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import Foundation
struct Photo : Decodable{
    var thumb: String
    var highres: String?
    var is_user_uploaded: Bool?
}
