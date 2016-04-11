//
//  ViewController.swift
//  MemeMe
//
//  Created by Eytan Biala on 9/28/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import MobileCoreServices

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField! {
        didSet {
            topTextField.text = topFieldDefaultValue
            topTextField.defaultTextAttributes = memeTextAttributes
            topTextField.textAlignment = .Center
            topTextField.delegate = self
        }
    }
    @IBOutlet weak var bottomTextField: UITextField! {
        didSet {
            bottomTextField.text = bottomFieldDefaultValue
            bottomTextField.defaultTextAttributes = memeTextAttributes
            bottomTextField.textAlignment = .Center
            bottomTextField.delegate = self
        }
    }

    let topFieldDefaultValue = "top".uppercaseString
    let bottomFieldDefaultValue = "bottom".uppercaseString

    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -2.0
    ]

    var cancelItem: UIBarButtonItem!
    var meme = Meme(topFieldText: "", bottomFieldText: "", originalImage: nil, memeImage: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.blackColor()

        let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(MemeEditorViewController.shareTapped(_:)))
        cancelItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(MemeEditorViewController.cancelTapped(_:)))

        navigationItem.setLeftBarButtonItem(shareItem, animated: false)
        navigationItem.setRightBarButtonItem(cancelItem, animated: false)

        let photoItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: #selector(MemeEditorViewController.cameraTapped(_:)))
        let albumItem = UIBarButtonItem(title: "Album", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MemeEditorViewController.albumTapped(_:)))
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = 88.0;

        navigationController?.toolbarHidden = false
        setToolbarItems([flexibleSpaceItem, photoItem, fixedSpaceItem, albumItem, flexibleSpaceItem], animated: false)

        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            photoItem.enabled = false
        }

        imageView.contentMode = .ScaleAspectFit

        view.sendSubviewToBack(imageView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = nil
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.utf8.count == 0 {
            if textField == topTextField {
                textField.text = topFieldDefaultValue
            } else if textField == bottomTextField {
                textField.text = bottomFieldDefaultValue
            }
        } else {
            if textField == topTextField {
                meme.topFieldText = textField.text!
            } else if textField == bottomTextField {
                meme.bottomFieldText = textField.text!
            }
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
        return false
    }

    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }


    func shareTapped(sender: UIBarButtonItem) {
        let image = generateMemedImage()

        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        share.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems, activityError) in
            if completed {
                // Add it to the memes array in the Application Delegate
                let object = UIApplication.sharedApplication().delegate
                let appDelegate = object as! AppDelegate
                appDelegate.memes.append(self.meme)
                self.dismiss()
            }
        }
        presentViewController(share, animated: true, completion: nil)
    }

    func dismiss() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func cancelTapped(sender: UIBarButtonItem) {
        imageView.image = nil
        topTextField.text = topFieldDefaultValue
        bottomTextField.text = bottomFieldDefaultValue
        resignFirstResponder()

        meme = Meme(topFieldText: "", bottomFieldText: "", originalImage: nil, memeImage: nil)

        // navigationController?.popViewControllerAnimated(true)
        dismiss()
    }

    func cameraTapped(sender: UIBarButtonItem) {
        presentImagePicker(.Camera)
    }

    func albumTapped(sender: UIBarButtonItem) {
        presentImagePicker(.SavedPhotosAlbum)
    }

    func presentImagePicker(type: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = type
        presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage

        imageView.image = selectedImage
        meme.originalImage = selectedImage

        dismissViewControllerAnimated(true, completion: nil)
    }

    func generateMemedImage() -> UIImage {

        let topBarHeight = CGRectGetHeight((navigationController?.navigationBar.frame)!) + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame);
        let bottomBarHeight = CGRectGetHeight((navigationController?.toolbar.frame)!);
        let viewHeight = CGRectGetHeight(view.frame) - topBarHeight - bottomBarHeight
        let viewFrame = CGRectMake(0, topBarHeight, CGRectGetWidth(view.frame), viewHeight)

        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let croppedImageRef = CGImageCreateWithImageInRect(memedImage.CGImage, viewFrame)
        let croppedImage: UIImage = UIImage(CGImage: croppedImageRef!)

        meme.memeImage = croppedImage

        return croppedImage
    }
}

