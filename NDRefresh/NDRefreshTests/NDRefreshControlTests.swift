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

    // MARK: - Public method tests

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

    func testConfigureForRefresh() {
        var frame = refreshView!.frame
        frame.size.width = 10.0
        refreshView!.frame = frame

        // Verify that refresh view frame is modified after configuration.
        XCTAssert(CGRectGetWidth(refreshView!.bounds) == 10.0, "Width should be 0")
        refreshControl?.configureForRefresh()
        XCTAssert(CGRectGetWidth(refreshView!.bounds) != 10.0, "Width should have been adjusted")
    }

    func testEndRefresh() {
        let expectation = expectationWithDescription("End refresh")
        self.scrollView!.contentOffset = CGPointMake(0, 20)
        self.scrollView!.contentInset = UIEdgeInsetsMake(30, 0, 0, 0)

        refreshControl?.endRefresh()

        expectation.fulfill()
        waitForExpectationsWithTimeout(0.5) {
            error in
            // Verify that contentOffset and contentInset are set back to the original state.
            XCTAssertEqual(self.scrollView!.contentOffset.y, 0.0)
            XCTAssertEqual(self.scrollView!.contentInset.top, 0.0)
        }
    }

    // MARK: - State transition related tests

    func testRefreshing() {
        let expectation = expectationWithDescription("Refreshing")

        refreshControl?.refreshState = .Refreshing

        expectation.fulfill()
        waitForExpectationsWithTimeout(0.5) {
            error in
            // Verify that contentOffset and contentInset are set back to the original state.
            XCTAssertEqual(self.scrollView!.contentOffset.y, -CGRectGetHeight(self.refreshView!.bounds))
            XCTAssertEqual(self.scrollView!.contentInset.top, CGRectGetHeight(self.refreshView!.bounds))

        }
    }

    // MARK: - Closure related tests

    func closureSetup() {
        // Set up the closures for guarding purpose.

        let defaultClosure: (refreshControl: NDRefreshControl) -> () = {
            refreshControl in
            XCTFail("Should not be called")
        }
        refreshControl?.renderIdleClosure = defaultClosure
        refreshControl?.renderTriggeredClosure = defaultClosure
        refreshControl?.renderPullingClosure = defaultClosure
        refreshControl?.renderReadyForRefreshClosure = defaultClosure
        refreshControl?.renderRefreshClosure = defaultClosure
    }

    func testClosureInvocation(inout closureReference: ((refreshControl: NDRefreshControl) -> ())?,
        state: NDRefreshControlState) {
        closureSetup()

        var called = false
        closureReference = {
            refreshControl in
            called = true
        }
        refreshControl?.refreshState = state
        XCTAssertTrue(called, "The closure should have been called")
    }

    func testIdleStateChange() {
        testClosureInvocation(&(refreshControl!.renderIdleClosure), state: NDRefreshControlState.Idle)
    }

    func testTriggeredStateChange() {
        testClosureInvocation(&(refreshControl!.renderTriggeredClosure), state: NDRefreshControlState.Triggered)
    }

    func testPullingStateChange() {
        testClosureInvocation(&(refreshControl!.renderPullingClosure), state: NDRefreshControlState.Pulling)
    }

    func testReadyForRefreshStateChange() {
        testClosureInvocation(&(refreshControl!.renderReadyForRefreshClosure),
            state: NDRefreshControlState.ReadyForRefresh)
    }

    func testRefreshingStateChange() {
        testClosureInvocation(&(refreshControl!.renderRefreshClosure),
            state: NDRefreshControlState.Refreshing)
    }

    // MARK: - Content offset releated tests

    class DraggableScrollView: UIScrollView {
        var draggingState = true
        override var dragging: Bool {
            get {
                return draggingState
            }
        }
    }

    func testChangeStateToTriggered() {
        let scrollView = DraggableScrollView(frame: scrollViewFrame)
        let refreshControl = NDRefreshControl(refreshView: refreshView!, scrollView: scrollView)
        refreshControl.refreshState = .Idle
        scrollView.contentOffset = CGPointMake(0, -100)
        XCTAssert(refreshControl.refreshState == .Triggered, "The refresh state should be triggered")
    }

    func testChangeStateToPulling() {
        let scrollView = DraggableScrollView(frame: scrollViewFrame)
        let refreshControl = NDRefreshControl(refreshView: refreshView!, scrollView: scrollView)
        refreshControl.refreshState = .Triggered
        scrollView.contentOffset = CGPointMake(0, -100)
        XCTAssert(refreshControl.refreshState == .Pulling, "The refresh state should be pulling")
    }

    func testChangeStateToReadyForRefresh() {
        let scrollView = DraggableScrollView(frame: scrollViewFrame)
        let refreshControl = NDRefreshControl(refreshView: refreshView!, scrollView: scrollView)
        refreshControl.refreshState = .Pulling
        scrollView.contentOffset = CGPointMake(0, -CGRectGetHeight(refreshView!.bounds))
        XCTAssert(refreshControl.refreshState == .ReadyForRefresh , "The refresh state should be ready for refresh")
    }

    func testChangeStateToPullingFromReadyForRefresh() {
        let scrollView = DraggableScrollView(frame: scrollViewFrame)
        let refreshControl = NDRefreshControl(refreshView: refreshView!, scrollView: scrollView)
        refreshControl.refreshState = .ReadyForRefresh
        scrollView.contentOffset = CGPointMake(0, -10)
        XCTAssert(refreshControl.refreshState == .Pulling, "The refresh state should be switched back to pulling")
    }

    func testChangeStateToIdle() {
        let scrollView = DraggableScrollView(frame: scrollViewFrame)
        scrollView.draggingState = false
        let refreshControl = NDRefreshControl(refreshView: refreshView!, scrollView: scrollView)
        refreshControl.refreshState = .Pulling
        scrollView.contentOffset = CGPointMake(0, -10)
        XCTAssert(refreshControl.refreshState == .Idle, "The refresh state should be reset idle")
    }

    func testChangeStateToRefreshing() {
        let scrollView = DraggableScrollView(frame: scrollViewFrame)
        scrollView.draggingState = false
        let refreshControl = NDRefreshControl(refreshView: refreshView!, scrollView: scrollView)
        refreshControl.refreshState = .ReadyForRefresh
        scrollView.contentOffset = CGPointMake(0, -10)
        XCTAssert(refreshControl.refreshState == .Refreshing, "The refresh state should be reset idle")
    }
}
