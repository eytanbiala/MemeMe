//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Eytan Biala on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {

    let reuseIdentifier = "MemeCell"

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewer = MemeViewerController()
        viewer.meme = memes[indexPath.item]
        navigationController?.pushViewController(viewer, animated: true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

        let meme = memes[indexPath.row]

        cell.imageView?.contentMode = .ScaleAspectFit
        cell.imageView?.image = meme.memeImage
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = String(format: "%@ %@", meme.topFieldText, meme.bottomFieldText)

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

            // Remove it from the memes array in the AppDelegate
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.removeAtIndex(indexPath.row)

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
}