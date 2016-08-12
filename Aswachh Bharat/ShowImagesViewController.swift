//
//  ShowImagesViewController.swift
//  Aswachh Bharat
//
//  Created by Vmock on 31/07/16.
//  Copyright © 2016 devup. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ShowImagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView:UITableView?
    let refreshControl:UIRefreshControl = UIRefreshControl()
    
    var images:JSON? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.backgroundColor = UIColor.clearColor()
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshControl.addTarget(self, action: #selector(ShowImagesViewController.loadData), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView!.addSubview(refreshControl)
        
        loadData()
    }
    
    func loadData() {
        _ = Alamofire.request(ImageRouter.All)
            .responseJSON { response in
                guard response.result.error == nil else {
                    print("Error: GET images")
                    print(response.result.error!)
                    return
                }
                
                if let value: AnyObject = response.result.value {
                    self.images = JSON(value)
                    self.tableView!.reloadData()
                    self.refreshControl.endRefreshing()
                }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.images != nil) {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let images = self.images {
            return images["results"].count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("images") as! ImageTableViewCell
        
        let image = self.images!["results"][indexPath.row]
        let coordinates:[Float] = image["location"]["coordinates"].arrayValue.map { $0.float! }
        
        let URL = NSURL(string: image["file"].description)!
        
        cell.mainImageView.af_setImageWithURL(URL)
        if coordinates.count > 0 {
            cell.location!.text = "\(coordinates[0]), \(coordinates[1])"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

