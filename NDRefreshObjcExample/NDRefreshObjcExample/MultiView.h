//
//  MultiView.h
//  NDRefreshObjcExample
//
//  Created by Daisuke Fujiwara on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiView : UIView

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *car;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

+ (instancetype)newFromNib;

@end
