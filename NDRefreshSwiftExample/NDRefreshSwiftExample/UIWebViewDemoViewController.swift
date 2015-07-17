//
//  UIWebViewDemoViewController.swift
//  NDRefreshSwiftExample
//
//  Created by Daisuke Fujiwara on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

import Foundation
import WebKit

import NDRefresh

class UIWebViewDemoViewController: UITableViewController {

    var refreshCtrl: NDRefreshControl?
    let cellReuseIdentifier = "ReuseIdentifier"

    // MARK: - Refresh control callback methods

    func renderRefreshHandler(refreshControl: NDRefreshControl) {
        // Emulate an actual refreshing scenario by introducing artifical delay.
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            refreshControl.endRefresh()
        }
    }

    // MARK: - View related methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a sample view to use when engaging with the refresh control.
        let webView = WKWebView(frame: CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 100))
        refreshCtrl = NDRefreshControl(refreshView: webView, scrollView: tableView)

        // Configure all the callbacks.
        refreshCtrl?.renderRefreshClosure = renderRefreshHandler

        // Table view set up.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // Set up the web view content from a html file in the bundle.
        let filePath = NSBundle.mainBundle().pathForResource("sample", ofType: "html")
        if let fileContent = String(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding, error: nil) {
            webView.loadHTMLString(fileContent, baseURL: nil)
        }
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