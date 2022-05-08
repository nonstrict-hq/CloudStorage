//
//  CloudSettings.swift
//  CloudStorage-iOS13
//
//  Created by Yang Xu on 2022/5/8
//  Copyright © 2022 Yang Xu. All rights reserved.
//
//  Follow me on Twitter: @fatbobman
//  My Blog: https://www.fatbobman.com
//

import CloudStorage
import Combine
import Foundation

class CloudSettings: ObservableObject {
    @CloudStorage("readyForAction") var readyForAction = false
    @CloudStorage("speed") var speed: Double = 0
    @CloudStorage("numberOfItems") var numberOfItems = 0
    @CloudStorage("ninjaTurtle") var ninjaTurtle = turtles[0]
    @CloudStorage("orientation") var orientation: String?
    @CloudStorage("favoriteColor") var favoriteColor = MyColor(.lightGray)
    @CloudStorage("planets") var planets: [String] = terrestrialPlanets
}
