//
//  UIImageViewDemoViewController.swift
//  NDRefreshSwiftExample
//
//  Created by Daisuke Fujiwara on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

import Foundation

import NDRefresh


class UIImageViewDemoViewController: UITableViewController {

    var refreshCtrl: NDRefreshControl?
    let cellReuseIdentifier = "ReuseIdentifier"

    // MARK: - Refresh control callback methods
    func renderIdleHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "IdleImage")
    }

    func renderRefreshHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "RefreshImage1")
        
        var imgListArray :NSMutableArray = []
        imgListArray.addObject(UIImage(named:"RefreshImage1")!)
        imgListArray.addObject(UIImage(named:"RefreshImage2")!)        
        
        view.animationImages = imgListArray as [AnyObject];
        view.animationDuration = 1
        view.startAnimating()        

        // Emulate an actual refreshing scenario by introducing artifical delay.
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            view.stopAnimating()
            refreshControl.endRefresh()
        }
    }

    func renderPullingHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "PullingImage")        
    }

    func renderReadyForRefreshHandler(refreshControl: NDRefreshControl) {
        var view = refreshControl.refreshView as! UIImageView
        view.image = UIImage(named: "ReadyForRefreshImage")
    }

    // MARK: - View related methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a sample view to use when engaging with the refresh control.
        let pullView = UIImageView(image: UIImage(named: "IdleImage"))
        refreshCtrl = NDRefreshControl(refreshView: pullView, scrollView: tableView)

        // Configure all the callbacks.
        refreshCtrl?.renderIdleClosure = renderIdleHandler
        refreshCtrl?.renderRefreshClosure = renderRefreshHandler
        refreshCtrl?.renderPullingClosure = renderPullingHandler
        refreshCtrl?.renderReadyForRefreshClosure = renderReadyForRefreshHandler

        // Table view set up.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // NOTE: configureForRefresh should be called when the view controller has completely laid out the view
        // and its subviews. If you call this method in viewDidLoad, the contentInset and contentOffset values
        // are not accurate due to the navigation bar and status bar.
        refreshCtrl!.configureForRefresh()
    }

    // MARK: - Table view related code

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Create a sample of 100 rows.
        return 100
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Use the label text to be the row number.
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = String(indexPath.row)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Clicking on any table view rows trigger refreshing.
        refreshCtrl?.beginRefresh()
    }
}