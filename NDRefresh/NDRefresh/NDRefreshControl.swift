//
//  NDRefreshControl.swift
//  NDRefresh
//
//  Created by Daisuke Fujiwara on 7/13/15.
//  Copyright (c) 2015 nextdoor.com. All rights reserved.
//

import UIKit

/**
Enumeration of possible refresh control states.

- Triggered:       A state that represents when the refresh sequence started.
                   Note that this state doesn't last long.
- Pulling:         A state where scroll view is being dragged and refresh view is being visible.
- ReadyForRefresh: A state where scroll view offset has exceeded the threshold while the refresh view is visible.
                   If the scroll view's dragging is stopped, it will launch into the refreshing process.
- Refreshing:      A state when the refreshing is occurring. (e.g. network request)
- Idle:            A state that when the control is not activated.
*/
enum NDRefreshControlState {
    case Triggered
    case Pulling
    case ReadyForRefresh
    case Refreshing
    case Idle
}

/// A class that manages the process of refresh view in accordance to the state of scroll view's scrolling.
public class NDRefreshControl: NSObject {
    // MARK: - View related properties
    public let refreshView: UIView
    public weak var scrollView: UIScrollView?
    private var originalInsetTop: CGFloat = 0
    private var originalYOffset: CGFloat = 0

    private var kvoContext = 0
    private let animationInterval = 0.25

    // MARK: - Callbacks

    // A set of callback closures that are mapped to various refresh control states.
    public var renderIdleClosure: ((refreshControl: NDRefreshControl) -> ())?
    public var renderTriggeredClosure: ((refreshControl: NDRefreshControl) -> ())?
    public var renderRefreshClosure: ((refreshControl: NDRefreshControl) -> ())?
    public var renderPullingClosure: ((refreshControl: NDRefreshControl) -> ())?
    public var renderReadyForRefreshClosure: ((refreshControl: NDRefreshControl) -> ())?

    // MARK: - State related variables

    var refreshState = NDRefreshControlState.Idle {
        didSet {
            switch (refreshState) {
            case .Idle:
                renderIdleClosure?(refreshControl: self)
            case .Triggered:
                renderTriggeredClosure?(refreshControl: self)
            case .Refreshing:
                // Keep the refresh view visible by creating an scroll view inset.
                UIView.animateWithDuration(animationInterval) {
                    self.scrollView!.contentOffset.y = self.originalYOffset -
                        CGRectGetHeight(self.refreshView.bounds)
                    self.scrollView!.contentInset.top = CGRectGetHeight(self.refreshView.bounds) + self.originalInsetTop
                }
                renderRefreshClosure?(refreshControl: self)
            case .Pulling:
                renderPullingClosure?(refreshControl: self)
            case .ReadyForRefresh:
                renderReadyForRefreshClosure?(refreshControl: self)
            }
        }
    }

    // MARK: - Initializers

    public init(refreshView: UIView, scrollView: UIScrollView) {
        self.refreshView = refreshView
        self.scrollView = scrollView
        super.init()

        self.scrollView?.addSubview(refreshView)
        self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .New | .Old, context: &kvoContext)

        setUpRefreshView()
    }

    deinit {
        self.scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &kvoContext)
    }

    // MARK: - View related methods

    private func setUpRefreshView() {
        if let scrollView = scrollView {
            // TODO (wenbin, dais): clean up frame calculation, very intrusive!!!
            let refreshViewHeight = CGRectGetHeight(refreshView.bounds) * CGRectGetWidth(scrollView.bounds) /
                CGRectGetWidth(refreshView.bounds)
            refreshView.frame = CGRectMake(0, -refreshViewHeight, CGRectGetWidth(scrollView.bounds), refreshViewHeight)
        }
    }

    // MARK: - Key value related methods

    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &kvoContext {
            super.observeValueForKeyPath(keyPath, ofObject: object,
                change: change, context: context)
            return
        }

        let newPoint = (change[NSKeyValueChangeNewKey] as! NSValue).CGPointValue()
        let oldPoint = (change[NSKeyValueChangeOldKey] as! NSValue).CGPointValue()
        handleContentOffset(newPoint, oldOffSet: oldPoint)
    }

    private func handleContentOffset(newOffset: CGPoint, oldOffSet: CGPoint) {
        if refreshState == .Refreshing {
            // Nothing to do here anymore since it's refreshing.
            return
        }

        if let scrollView = self.scrollView {
            let dragDistance = (newOffset.y - originalYOffset)
            if refreshState == .Idle && scrollView.dragging {
                if newOffset.y < oldOffSet.y && dragDistance <= 0 {
                    // Idle, pulling down, refresh view is now visible.
                    refreshState = .Triggered
                } else {
                    // The refresh view is not being visible but dragging is happening.
                }
            } else if refreshState == .Triggered || refreshState == .Pulling || refreshState == .ReadyForRefresh {
                if !scrollView.dragging {
                    if refreshState == .ReadyForRefresh {
                        // Whenever we are ready & stopped dragging, then start refreshing.
                        refreshState = .Refreshing
                    } else {
                        // Otherwise, go back to the idle state.
                        refreshState = .Idle
                    }
                } else {
                    // Determine whether enough dragging happened to be ready for refreshing.
                    let readyForRefresh = dragDistance <= -CGRectGetHeight(refreshView.bounds)
                    refreshState = readyForRefresh ? .ReadyForRefresh : .Pulling
                }
            } else {
                // Idle but without dragging.
            }
        }
    }

    // MARK: - Public methods

    /**
    This methods configures all the view related states for refresh control. Note that this needs to be called
    from a place where scroll view is laid out by its parent view.
    */
    public func configureForRefresh() {
        if let scrollView = scrollView  {
            originalInsetTop = scrollView.contentInset.top
            originalYOffset = scrollView.contentOffset.y
            setUpRefreshView()
        }
    }

    /**
    This methods starts the refresh squence programatically; e.g. By a button press.
    Note that you don't need to call this method to activate the refresh sequence via pull to refresh motion.
    */
    public func beginRefresh() {
        if (refreshState == .Idle) {
            refreshState = .Refreshing
        }
    }

    /**
    This method needs to be called when the refresh sequence is done; e.g. Have receieved the network response.
    */
    public func endRefresh() {
        UIView.animateWithDuration(animationInterval, animations: {
            self.scrollView?.contentOffset.y = self.originalYOffset
            self.scrollView?.contentInset.top = self.originalInsetTop
            }) {
                finished in
                self.refreshState = .Idle
        }
    }
}