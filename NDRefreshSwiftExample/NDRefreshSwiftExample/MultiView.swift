//
//  MultiView.swift
//  NDRefreshSwiftExample
//
//  Created by Wenbin Fang on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

import UIKit


class MultiView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var car: UIImageView!
    
    static func newFromNib() -> MultiView {
        let views = NSBundle(forClass: MultiView.self).loadNibNamed("MultiView", owner: self, options: nil) as! [MultiView]
        return views.first!
    }
}
