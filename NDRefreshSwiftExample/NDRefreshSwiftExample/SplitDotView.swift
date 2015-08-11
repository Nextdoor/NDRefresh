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
        let views = NSBundle(forClass: SplitDotView.self).loadNibNamed("SplitDotView",
            owner: self, options: nil) as! [SplitDotView]
        return views.first!
    }
    
    private func offsetDot(dot: UIView, xOffset: CGFloat, yOffset: CGFloat) {
        dot.transform = CGAffineTransformTranslate(dot.transform, xOffset, yOffset)
    }

    private func resetDot(dot: UIView) {
        dot.transform = CGAffineTransformIdentity
    }
    
    private func animateRefreshing() {
        if !animating {
            return
        }

        let options = UIViewAnimationOptions.CurveEaseOut
        let xOffset: CGFloat = 8.0
        let yOffset: CGFloat = 8.0
        let springDamping: CGFloat = 0.6
        let initialVelocity: CGFloat = 10

        // Reset the dots before animating as a safe guard.
        for dot in [firstDot, secondDot, thirdDot, fourthDot] {
            self.resetDot(dot)
        }

        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialVelocity, options: options, animations: {
            self.offsetDot(self.firstDot, xOffset: -xOffset, yOffset: 0)
            self.offsetDot(self.secondDot, xOffset: xOffset, yOffset: 0)
            self.offsetDot(self.thirdDot, xOffset: -xOffset, yOffset: 0)
            self.offsetDot(self.fourthDot, xOffset: xOffset, yOffset: 0)
        }, completion: nil)

        UIView.animateWithDuration(0.4, delay: 0.5, usingSpringWithDamping: springDamping,
            initialSpringVelocity: initialVelocity, options: options, animations: {
            self.offsetDot(self.firstDot, xOffset: 0, yOffset: -yOffset)
            self.offsetDot(self.secondDot, xOffset: 0, yOffset: -yOffset)
            self.offsetDot(self.thirdDot, xOffset: 0, yOffset: yOffset)
            self.offsetDot(self.fourthDot, xOffset: 0, yOffset: yOffset)
        }, completion: nil)

        UIView.animateWithDuration(0.4, delay: 0.9, options: options, animations: {
            let offset: CGFloat = 8.0
            self.offsetDot(self.firstDot, xOffset: -offset, yOffset: -offset)
            self.offsetDot(self.secondDot, xOffset: offset, yOffset: -offset)
            self.offsetDot(self.thirdDot, xOffset: -offset, yOffset: offset)
            self.offsetDot(self.fourthDot, xOffset: offset, yOffset: offset)
        }, completion: nil)

        UIView.animateWithDuration(0.2, delay: 1.3, options: options, animations: {
            self.resetDot(self.firstDot)
            self.resetDot(self.secondDot)
            self.resetDot(self.thirdDot)
            self.resetDot(self.fourthDot)
        }) {
            finished in
            // Perpetually animate until the flag is not set.
            self.animateRefreshing()
        }

    }
    
    func startAnimation() {
        if animating {
            return
        }
        animating = true
        animateRefreshing()
    }
    
    func stopAnimation() {
        animating = false
    }
}