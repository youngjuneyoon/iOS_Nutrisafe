//
//  Profile.swift
//  NutriSafe
//
//  Created by Yang on 11/13/19.
//  Copyright © 2019 apple－pc. All rights reserved.
//

import Foundation
import UIKit

var currentProfile = Profile(name: "default", allergens:[], diet: nil)


//struct CurrentProfile {
//    var profile: Profile
//}

struct Profile {
    var name: String
    var allergens: [String]
    var diet: Diet?
}
