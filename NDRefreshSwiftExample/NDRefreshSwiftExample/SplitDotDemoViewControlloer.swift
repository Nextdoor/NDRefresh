//
//  SplitDotDemoViewController.swift
//  NDRefreshSwiftExample
//
//  Created by Wenbin Fang on 7/19/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

import NDRefresh

class SplitDotDemoViewController: UITableViewController {
    
    var refreshCtrl: NDRefreshControl?
    let cellReuseIdentifier = "ReuseIdentifier"
    var originalYOffset: CGFloat?
    
    // MARK: - Refresh control callback methods
    func renderIdleHandler(refreshControl: NDRefreshControl) {
        let view = refreshControl.refreshView as! SplitDotView
        view.stopAnimation()
    }
    
    func renderRefreshHandler(refreshControl: NDRefreshControl) {
        let view = refreshControl.refreshView as! SplitDotView
        view.startAnimation()
        
        // Emulate an actual refreshing scenario by introducing artifical delay.
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(4 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            view.stopAnimation()
            refreshControl.endRefresh()
        }
    }
    
    // MARK: - View related methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a sample view to use when engaging with the refresh control.
        let pullView = SplitDotView.newFromNib()
        pullView.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 100)
        pullView.layoutIfNeeded()
        refreshCtrl = NDRefreshControl(refreshView: pullView, scrollView: tableView)
        
        // Configure all the callbacks.
        refreshCtrl?.renderIdleClosure = renderIdleHandler
        refreshCtrl?.renderRefreshClosure = renderRefreshHandler
        
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
