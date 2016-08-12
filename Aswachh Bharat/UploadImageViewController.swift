//
//  UploadImageViewController.swift
//  Aswachh Bharat
//
//  Created by Sakthi Ganesh on 07/08/16.
//  Copyright © 2016 devup. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class UploadImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var location:String?
    var imageURL:NSURL?
    
    @IBAction func openCameraButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func upload(sender: AnyObject) {
        if let _ = self.imageURL {
        Alamofire
            .upload(
                .POST,
                ImageRouter.Upload.URLRequest.URL!,
                multipartFormData: { (multipartformdata) in
                    if (self.imageURL!.pathExtension == "JPG"
                        || self.imageURL!.pathExtension == "JPEG") {
                        if let data = UIImageJPEGRepresentation(self.imageView.image!, 100.0) {
                            multipartformdata.appendBodyPart(data: data, name: "file", fileName: (self.imageURL?.pathComponents?.last)!, mimeType: "image/jpg")
                        }
                    }
                    if self.imageURL!.pathExtension == "PNG" {
                        if let data = UIImagePNGRepresentation(self.imageView.image!) {
                            multipartformdata.appendBodyPart(data: data, name: "file", fileName: (self.imageURL?.pathComponents?.last)!, mimeType: "image/png")
                        }
                    }
                    
                    if let data = self.location?.dataUsingEncoding(NSUTF8StringEncoding) {
                        multipartformdata.appendBodyPart(data: data, name: "location")
                    }
                },
                encodingCompletion: { (encodingResult) in
                    switch encodingResult {
                    case .Success( let upload, _, _):
                        upload.responseString(completionHandler: { (response) in
                            if response.result.description == "SUCCESS" {
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            } else {
                                let alert = UIAlertController(title: "Failed", message: "Try after somtime", preferredStyle: .Alert)
                                self.presentViewController(alert, animated: true, completion: { 
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                })
                            }
                        })
                    break
                    
                    case .Failure( let err):
                    break
                    }
                }
        )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
        } else {
            self.location = nil
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.location = JSON(["type":"Point","coordinates":[locValue.latitude, locValue.longitude]]).rawString()
        self.locationLabel!.text = "Location = \(locValue.latitude) \(locValue.longitude)"
        locationManager.stopUpdatingLocation()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL
        self.imageView.contentMode = .ScaleAspectFill
        self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismissViewControllerAnimated(true){}
    }
}