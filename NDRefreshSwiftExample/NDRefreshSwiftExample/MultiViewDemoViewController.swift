//
//  MultiViewDemoViewController.swift
//  NDRefreshSwiftExample
//
//  Created by Wenbin Fang on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

import Foundation

import NDRefresh

class MultiViewDemoViewController: UITableViewController {
    
    var refreshCtrl: NDRefreshControl?
    let cellReuseIdentifier = "ReuseIdentifier"
    var originalYOffset: CGFloat?
    
    // MARK: - Refresh control callback methods
    func renderIdleHandler(refreshControl: NDRefreshControl) {
        let view = refreshControl.refreshView as! MultiView
        view.title.hidden = true
        view.spinner.hidden = true
        view.car.hidden = true      
    }
    
    func renderRefreshHandler(refreshControl: NDRefreshControl) {
        let view = refreshControl.refreshView as! MultiView
        view.title.text = "Loading ..."        
        view.spinner.startAnimating()
        view.title.hidden = false
        view.spinner.hidden = false
        view.car.hidden = true    
        
        // Emulate an actual refreshing scenario by introducing artifical delay.
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            view.spinner.stopAnimating()
            refreshControl.endRefresh()
        }
    }
    
    func renderPullingHandler(refreshControl: NDRefreshControl) {
        let view = refreshControl.refreshView as! MultiView
        let offset = refreshCtrl?.scrollView?.contentOffset
        view.title.hidden = true
        view.spinner.hidden = true
        view.car.hidden = false
        let scale =  (abs(offset!.y) - abs(originalYOffset!)) / CGRectGetHeight(view.bounds)
        
        // 350 * 0 -> 1
        let x = CGRectGetWidth(refreshControl.scrollView!.bounds) * scale
        view.car.frame = CGRectMake(x, view.car.frame.origin.y,
            view.car.frame.size.width, view.car.frame.size.height)
    }
    
    func renderReadyForRefreshHandler(refreshControl: NDRefreshControl) {
        let view = refreshControl.refreshView as! MultiView
        view.title.text = "Release to refresh ..."
        view.title.hidden = false
        view.spinner.hidden = true
        view.car.hidden = true        
    }
    
    // MARK: - View related methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a sample view to use when engaging with the refresh control.
        let pullView = MultiView.newFromNib()
        pullView.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 100)
        pullView.layoutIfNeeded()
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
        originalYOffset = tableView.contentOffset.y          
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