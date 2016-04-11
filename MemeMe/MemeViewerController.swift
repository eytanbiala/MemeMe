//
//  MemeViewerController.swift
//  MemeMe
//
//  Created by Eytan Biala on 4/11/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class MemeViewerController: UIViewController {

    var meme : Meme! = nil

    override func viewDidLoad() {
        let imageView = UIImageView(frame: view.frame)
        imageView.image = meme.memeImage
        imageView.contentMode = .ScaleAspectFit
        view.addSubview(imageView)
    }
}
