//
//  MultiView.m
//  NDRefreshObjcExample
//
//  Created by Daisuke Fujiwara on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

#import "MultiView.h"

@implementation MultiView

+ (instancetype)newFromNib {
    NSArray *views = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"MultiViewObjc" owner:self options:nil];
    return views.firstObject;
}

@end
