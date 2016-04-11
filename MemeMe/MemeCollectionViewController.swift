//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Eytan Biala on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

let reuseIdentifier = "MyCell"

class MemeCollectionViewController: UICollectionViewController {

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        collectionView?.reloadData()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

        for subview in cell.subviews {
            subview.removeFromSuperview()
        }

        let meme = memes[indexPath.item]

        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .ScaleAspectFit
        imageView.image = meme.memeImage
        cell.addSubview(imageView)

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let viewer = MemeViewerController()
        viewer.meme = memes[indexPath.item]
        navigationController?.pushViewController(viewer, animated: true)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 88, height: 88);
    }
}