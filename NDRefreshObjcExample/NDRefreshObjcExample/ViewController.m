//
//  ViewController.m
//  NDRefreshObjcExample
//
//  Created by Daisuke Fujiwara on 7/14/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//
//  A sample code of using NDRefreshControl from Objective-C code base.
//

#import "ViewController.h"

@import NDRefresh;

@interface ViewController ()

@property (nonatomic, strong) NDRefreshControl *control;

@end

@implementation ViewController

static NSString *cellReuseIdentifier = @"ReuseIdentifier";

#pragma mark - View related methods

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create a sample view to use when engaging with the refresh control.
    UILabel *pullView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 64)];
    pullView.textAlignment = NSTextAlignmentCenter;
    self.control = [[NDRefreshControl alloc] initWithRefreshView:pullView scrollView:self.tableView];

    // Configure all the callbacks and update the label text accordingly.
    self.control.renderIdleClosure = ^(NDRefreshControl *refreshControl) {
        ((UILabel *)(refreshControl.refreshView)).text = @"ObjC - Idle state";
    };
    self.control.renderTriggeredClosure = ^(NDRefreshControl *refreshControl) {
        ((UILabel *)(refreshControl.refreshView)).text = @"ObjC - Triggered";
    };
    self.control.renderPullingClosure = ^(NDRefreshControl *refreshControl) {
        ((UILabel *)(refreshControl.refreshView)).text = @"ObjC - Pulling...";
    };
    self.control.renderReadyForRefreshClosure = ^(NDRefreshControl *refreshControl) {
        ((UILabel *)(refreshControl.refreshView)).text = @"ObjC - Pulling, please release to refresh...";
    };
    self.control.renderRefreshClosure = ^(NDRefreshControl *refreshControl) {
        ((UILabel *)(refreshControl.refreshView)).text = @"ObjC - Refreshing...";

        // Emulate an actual refreshing scenario by introducing artifical delay.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
