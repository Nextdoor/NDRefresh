//
//  NDRefreshTests.swift
//  NDRefreshTests
//
//  Created by Daisuke Fujiwara on 7/14/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

import UIKit
import XCTest

import NDRefresh


class NDRefreshControlTests: XCTestCase {

    var refreshControl: NDRefreshControl?
    var refreshView: UIView?
    var scrollView: UIScrollView?
    
    var refreshViewFrame: CGRect {
        return CGRectMake(0, 0, 400, 200)
    }
    
    var scrollViewFrame: CGRect {
        return CGRectMake(0, 0, 320, 600)
    }
    
    override func setUp() {
        super.setUp()
        
        refreshView = UIView(frame: refreshViewFrame)
        scrollView = UIScrollView(frame: scrollViewFrame)
        refreshControl = NDRefreshControl(refreshView: refreshView!,
            scrollView: scrollView!)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBeginRefreshIdleToRefreshing() {
        refreshControl?.beginRefresh()
        if let state = refreshControl?.refreshState {
            XCTAssertEqual(state, NDRefreshControlState.Refreshing,
                "If state is idle, change it to refreshing")            
        } else {
            XCTFail("Can't reach here!")
        }
    }

    func testBeginRefreshNonIdle() {
        refreshControl?.refreshState = NDRefreshControlState.Pulling
        refreshControl?.beginRefresh()
        if let state = refreshControl?.refreshState {
            XCTAssertEqual(state, NDRefreshControlState.Pulling,
                "If state isn't idle, shouldn't change it")            
        } else {
            XCTFail("Can't reach here!")
        }
    }    
}
