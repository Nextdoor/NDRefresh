//
//  UIImageViewDemoViewController.m
//  NDRefreshObjcExample
//
//  Created by Wenbin Fang on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

#import "UIImageViewDemoViewController.h"

@import NDRefresh;

@interface UIImageViewDemoViewController ()

@property (nonatomic, strong) NDRefreshControl *control;

@end

static NSString *cellReuseIdentifier = @"ReuseIdentifier";

@implementation UIImageViewDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a sample view to use when engaging with the refresh control.
    UIImageView *pullView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IdleImage"]];
    self.control = [[NDRefreshControl alloc] initWithRefreshView:pullView scrollView:self.tableView];
    
    // Configure all the callbacks and update the label text accordingly.
    self.control.renderIdleClosure = ^(NDRefreshControl *refreshControl) {
        ((UIImageView *)(refreshControl.refreshView)).image = [UIImage imageNamed:@"IdleImage"];
    };
    self.control.renderPullingClosure = ^(NDRefreshControl *refreshControl) {
        ((UIImageView *)(refreshControl.refreshView)).image = [UIImage imageNamed:@"PullingImage"];
    };
    self.control.renderReadyForRefreshClosure = ^(NDRefreshControl *refreshControl) {
        ((UIImageView *)(refreshControl.refreshView)).image = [UIImage imageNamed:@"ReadyForRefreshImage"];
    };
    self.control.renderRefreshClosure = ^(NDRefreshControl *refreshControl) {
        UIImageView* view = (UIImageView *)(refreshControl.refreshView);
        NSArray *animationArray=[NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"RefreshImage1"],
                                 [UIImage imageNamed:@"RefreshImage2"],
                                 nil];
        view.animationImages = animationArray;
        view.animationDuration = 1;
        [view startAnimating];
        
        // Emulate an actual refreshing scenario by introducing artifical delay.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view stopAnimating];
            [refreshControl endRefresh];
        });
    };
    
    // Table view set up.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // NOTE: configureForRefresh should be called when the view controller has completely laid out the view
    // and its subviews. If you call this method in viewDidLoad, the contentInset and contentOffset values
    // are not accurate due to the navigation bar and status bar.
    [self.control configureForRefresh];
}



#pragma mark - Table view related code

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Create a sample of 100 rows.
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Use the label text to be the row number.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Clicking on any table view rows trigger refreshing.
    [self.control beginRefresh];
}


@end
