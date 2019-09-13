//
//  ViewController.swift
//  Instagrid_master
//
//  Created by Caroline Zaini on 02/08/2019.
//  Copyright © 2019 Caroline Zaini. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var viewToShare: LayoutView!
    @IBOutlet weak var swipeStackView: UIStackView!
    
    // MARK: - Properties
    private var _imageTapped: UIImageView?
    // Make an instance of ImagePickerController.
    private let _imagePicker = UIImagePickerController()
    private var _effects = Effects()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _imagePicker.delegate = self
        viewToShare.defaultLayout()
        _effects.shadow(viewToShare)
        swipeDirection()
    }
    
    // MARK: Actions
    /// Connexion with the grid button.
    @IBAction func didTapGridButton(_ sender: UIButton) {
        viewToShare.gridButtonSelected(sender)
    }
    
    /// Connexion with 4 tapGestures on storyboard.
    @IBAction func tapToPickPhoto(_ sender: UITapGestureRecognizer) {
        tapGesture(sender)
    }
    
    /// The method for tapGesture.
    private func tapGesture(_ sender: UITapGestureRecognizer) {
        viewToShare.mainCollection.forEach { image in
            // Look at the centroid of the touches involved for the tap gesture.
            let touchPoint = sender.location(in: image)
            // If the user touch the image.
            if image.point(inside: touchPoint, with: nil) {
                _imageTapped = image
                alertSelectSourcePhotos()
            }
        }
    }
    
    /// Select the source, Library or Camera.
    private func alertSelectSourcePhotos() {
        let alertController = UIAlertController(title: "Import a photo", message: "Choose a source", preferredStyle: .alert)
        // add an action to the alert and open Library.
        alertController.addAction(UIAlertAction(title: "From Library", style: .default, handler: { (action) in
            self.openLibrary()
        }))
        // add an action to the alert and open Camera.
        alertController.addAction(UIAlertAction(title: "To take a photo", style: .default, handler: { (action) in
            self.openCamera()
        }))
        // add the cancel action.
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        // display it.
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Select photos from library.
    private func openLibrary() {
        _imagePicker.sourceType = .photoLibrary
        _imagePicker.allowsEditing = true
        present(_imagePicker, animated: true, completion: nil)
    }
    
    /// Use camera to take pictures.
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            _imagePicker.sourceType = .camera
            present(_imagePicker, animated: true, completion: nil)
        } else {
            self.presentAlert(title: "Ooops", message: "You don't have a camera", isShareAlert: false)
        }
    }
    
    /// Add the swipe gesture for each direction.
    private func swipeDirection() {
        // Adding two gesture up and left.
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .left]
        directions.forEach { direction in
            // Initialisation of the swipeGestureRecognizer.
            let _swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(gesture:)))
            swipeStackView.addGestureRecognizer(_swipeGesture)
            _swipeGesture.direction = direction
        }
    }
    
    /// handle the gesture for the swipe.
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up && UIDevice.current.orientation.isPortrait {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.swipeMoveUp(stackview: self.swipeStackView)
            }) { (finished) in
                self.swipeMoveBack(stackview: self.swipeStackView)
            }
                conditionsToShare()
        } else if gesture.direction == .left && UIDevice.current.orientation.isLandscape {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                self.swipeMoveLeft(stackview: self.swipeStackView)
            }) { (finished) in
                self.swipeMoveBack(stackview: self.swipeStackView)
            }
                conditionsToShare()
        }
    }
    
    /// Define swipe movement.
    private func swipeMoveUp(stackview: UIStackView) {
        stackview.transform = CGAffineTransform(translationX: 0, y: -40)
    }
    private func swipeMoveLeft(stackview: UIStackView) {
        stackview.transform = CGAffineTransform(translationX: -40, y: 0)
    }
    private func swipeMoveBack(stackview: UIStackView) {
        stackview.transform = .identity
    }
    
    /// Conditions to share when the user swipe.
    private func conditionsToShare() {
        if isMissingPhoto() {
            presentAlert(title: "Oups!", message: "Some photos are missing", isShareAlert: false)
        } else {
            self.share()
        }
    }
     /// Check if the grid is complete before sharing.
    func isMissingPhoto() -> Bool {
        switch viewToShare.layoutSelected {
        case .layout1:
            if viewToShare.topRightImageView.image == #imageLiteral(resourceName: "Plus") ||  viewToShare.bottomRightImageview.image == #imageLiteral(resourceName: "Plus") ||
                viewToShare.bottomLeftImageView.image == #imageLiteral(resourceName: "Plus") {
               return true
        }
        case .layout2:
            if viewToShare.topLeftImageView.image == #imageLiteral(resourceName: "Plus") || viewToShare.topRightImageView.image == #imageLiteral(resourceName: "Plus") || viewToShare.bottomRightImageview.image == #imageLiteral(resourceName: "Plus") {
                return true
            }
        case .layout3:
            if viewToShare.topLeftImageView.image == #imageLiteral(resourceName: "Plus") || viewToShare.topRightImageView.image == #imageLiteral(resourceName: "Plus") || viewToShare.bottomLeftImageView.image == #imageLiteral(resourceName: "Plus") || viewToShare.bottomRightImageview.image == #imageLiteral(resourceName: "Plus") {
                return true
            }
        }
        return false
    }
    
    /// Convert the viewToShare.
    private func convertToImage(view: UIView) -> UIImage? {
        // pass it the size,  the image should be opaque and the currnt scale
        UIGraphicsBeginImageContextWithOptions(view.frame.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: viewToShare.bounds, afterScreenUpdates: true)
        // give a context and extract a UIImage from the rendering.
        if let context = UIGraphicsGetCurrentContext(), let getImage = UIGraphicsGetImageFromCurrentImageContext() {
            view.layer.render(in: context)
            // when it finished, free up the memory from your rendering.
            UIGraphicsEndImageContext()
            return getImage
        }
        return nil
    }
    
    /// Share the viewToShare.
    private func share() {
        // Convert the image.
        if let image = convertToImage(view: viewToShare) {
            let shareContent = [image]
            let activityController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
            // Inside this closure we can check the activity type.
            activityController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in if completed {
                    self.presentAlert(title: "🤘", message: "You're image have been shared with succes", isShareAlert: true)
                    self._effects.blur(self.viewToShare)
                }
            }
            present(activityController, animated: true, completion: nil)
        }
    }
    

}

extension ViewController {
    
    private func presentAlert(title: String, message: String, isShareAlert: Bool) {
        // Create the alert controller.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Settings button.
        let answer = UIAlertAction(title: "OK", style:  .default, handler: { (action: UIAlertAction!) in
            if isShareAlert {
                self.resetLayout()
            }
        })
        // Add the action.
        alertController.addAction(answer)
        // Show the alert.
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Reset the default layout.
    private func resetLayout() {
        self.viewToShare.resetImageLayout()
        self._effects.defaultLayoutAnimation(viewToShare)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {  
     // When the user pick something.
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let photoToLoad = _imageTapped else { return }
        // if the image is edited with "allowsEditing", check if it's an UIImage.
        if let editedImage = info[.editedImage] as? UIImage {
            photoToLoad.image = editedImage
            photoToLoad.contentMode = .scaleAspectFill
          // If the image is original.
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoToLoad.image = originalImage
            photoToLoad.contentMode = .scaleAspectFill

        }
        // CLose the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // When the user taps the "Cancel" button.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
