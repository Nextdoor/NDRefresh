//
//  MultiViewDemoViewController.m
//  NDRefreshObjcExample
//
//  Created by Daisuke Fujiwara on 7/16/15.
//  Copyright (c) 2015 Nextdoor, Inc. All rights reserved.
//

#import "MultiViewDemoViewController.h"

@import NDRefresh;
#import "MultiView.h"

@interface MultiViewDemoViewController()

@property (nonatomic, strong) NDRefreshControl *control;
@property (nonatomic, assign) CGFloat originalYOffset;

@end


@implementation MultiViewDemoViewController

static NSString *cellReuseIdentifier = @"ReuseIdentifier";

#pragma mark - View related methods

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create a sample view to use when engaging with the refresh control.
    MultiView *multiView = [MultiView newFromNib];
    multiView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 100);
    self.control = [[NDRefreshControl alloc] initWithRefreshView:multiView scrollView:self.tableView];

    // Configure all the callbacks and update the label text accordingly.
    self.control.renderIdleClosure = ^(NDRefreshControl *refreshControl) {
        MultiView *view = (MultiView *)refreshControl.refreshView;
        view.title.hidden = YES;
        view.activityIndicator.hidden = YES;
        view.car.hidden = YES;
    };
    self.control.renderPullingClosure = ^(NDRefreshControl *refreshControl) {
        MultiView *view = (MultiView *)refreshControl.refreshView;
        view.title.hidden = YES;
        view.activityIndicator.hidden = YES;
        view.car.hidden = NO;

        CGPoint offset = refreshControl.scrollView.contentOffset;
        CGFloat scale = (fabs(offset.y) - fabs(self.originalYOffset)) / CGRectGetHeight(view.bounds);
        CGFloat x = CGRectGetWidth(refreshControl.scrollView.bounds) * scale;
        view.car.frame = CGRectMake(x, CGRectGetMinY(view.car.frame),
                                    CGRectGetWidth(view.car.bounds), CGRectGetHeight(view.car.bounds));
    };
    self.control.renderReadyForRefreshClosure = ^(NDRefreshControl *refreshControl) {
        MultiView *view = (MultiView *)refreshControl.refreshView;
        view.title.text = @"Release to refresh...";
        view.title.hidden = NO;
        view.activityIndicator.hidden = YES;
        view.car.hidden = YES;
    };
    self.control.renderRefreshClosure = ^(NDRefreshControl *refreshControl) {
        MultiView *view = (MultiView *)refreshControl.refreshView;
        [view.activityIndicator startAnimating];
        view.title.text = @"Loading ...";
        view.title.hidden = NO;
        view.car.hidden = YES;
        view.activityIndicator.hidden = NO;

        // Emulate an actual refreshing scenario by introducing artifical delay.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view.activityIndicator stopAnimating];
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
    self.originalYOffset = self.tableView.contentOffset.y;
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