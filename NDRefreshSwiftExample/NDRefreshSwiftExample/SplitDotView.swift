//
//  SplitDotView.swift
//  NDRefreshSwiftExample
//
//  Created by Wenbin Fang on 7/19/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

import UIKit

class SplitDotView: UIView {
    
    @IBOutlet weak var firstDot: UIView!
    @IBOutlet weak var secondDot: UIView!
    @IBOutlet weak var thirdDot: UIView!
    @IBOutlet weak var fourthDot: UIView!
    
    private var animating: Bool = false
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override func awakeFromNib() {
        firstDot.layer.cornerRadius = (CGRectGetWidth(firstDot.bounds) / 2.0);
        secondDot.layer.cornerRadius = (CGRectGetWidth(firstDot.bounds) / 2.0);
        thirdDot.layer.cornerRadius = (CGRectGetWidth(firstDot.bounds) / 2.0);
        fourthDot.layer.cornerRadius = (CGRectGetWidth(firstDot.bounds) / 2.0);
    }
    
    required init(coder aDecoder: NSCoder) {
        // do nothing
        super.init(coder: aDecoder)
    }
    
    static func newFromNib() -> SplitDotView {
        let views = NSBundle(forClass: SplitDotView.self).loadNibNamed("SplitDotView", owner: self, options: nil) as! [SplitDotView]
        return views.first!
    }
    
    private func offsetDot(dot: UIView, xOffset: CGFloat, yOffset: CGFloat) {
        dot.frame = CGRectMake(CGRectGetMinX(dot.frame) + xOffset, CGRectGetMinY(dot.frame) + yOffset,
            CGRectGetWidth(dot.bounds), CGRectGetHeight(dot.bounds))
    }
    
    private func animateRefreshing() {
        if !animating {
            return
        }
        
        let duration = 1.0
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModeLinear
        let offset: CGFloat = 20.0
        
        // Spliting from one to two sets
        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/4) {
                self.offsetDot(self.firstDot, xOffset: -offset, yOffset: 0)
                self.offsetDot(self.secondDot, xOffset: offset, yOffset: 0)
                self.offsetDot(self.thirdDot, xOffset: -offset, yOffset: 0)
                self.offsetDot(self.fourthDot, xOffset: offset, yOffset: 0)
            }
            
            UIView.addKeyframeWithRelativeStartTime(1/4, relativeDuration: 1/4) {
                self.offsetDot(self.firstDot, xOffset: 0, yOffset: -offset)
                self.offsetDot(self.secondDot, xOffset: 0, yOffset: -offset)
                self.offsetDot(self.thirdDot, xOffset: 0, yOffset: offset)
                self.offsetDot(self.fourthDot, xOffset: 0, yOffset: offset)
            }
            
            UIView.addKeyframeWithRelativeStartTime(2/4, relativeDuration: 1/4) {
                self.offsetDot(self.firstDot, xOffset: 0, yOffset: offset)
                self.offsetDot(self.secondDot, xOffset: 0, yOffset: offset)
                self.offsetDot(self.thirdDot, xOffset: 0, yOffset: -offset)
                self.offsetDot(self.fourthDot, xOffset: 0, yOffset: -offset)
            }
            
            UIView.addKeyframeWithRelativeStartTime(3/4, relativeDuration: 1/4) {
                self.offsetDot(self.firstDot, xOffset: offset, yOffset: 0)
                self.offsetDot(self.secondDot, xOffset: -offset, yOffset: 0)
                self.offsetDot(self.thirdDot, xOffset: offset, yOffset: 0)
                self.offsetDot(self.fourthDot, xOffset: -offset, yOffset: 0)
            }
            }) {
                finished in
                self.animateRefreshing()
        }
    }
    
    func startAnimation() {
        animating = true
        animateRefreshing()
    }
    
    func stopAnimation() {
        animating = false
    }
}