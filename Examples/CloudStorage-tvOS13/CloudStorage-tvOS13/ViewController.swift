//
//  ViewController.swift
//  CloudStorage-tvOS13
//
//  Created by Tom Lokhorst on 2021-03-27.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let controller = UIHostingController(rootView: ContentView())
        controller.willMove(toParent: self)
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
        controller.didMove(toParent: self)
    }


}

