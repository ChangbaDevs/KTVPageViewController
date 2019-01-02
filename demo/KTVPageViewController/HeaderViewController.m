//
//  HeaderViewController.m
//  KTVPageViewController
//
//  Created by yaoyingtao on 2019/1/2.
//  Copyright © 2019 yaoyingtao. All rights reserved.
//

#import "HeaderViewController.h"
#import "DemoChildViewController.h"
#import "KTVSegmentedControl.h"

@interface HeaderViewController () <KTVPageViewControllerDelegate, KTVPageViewControllerDataSource>
@property (nonatomic, strong) DemoChildViewController *firstController;
@property (nonatomic, strong) DemoChildViewController *secondController;
@property (nonatomic, strong) DemoChildViewController *thirdController;

@property (nonatomic, strong) KTVSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *headerView;

@end

@implementation HeaderViewController
#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"header";
    [self createChildControllers];
    [self createHeadView];
    [self createSegementControl];
    self.dataSource = self;
    self.delegate = self;
}

- (void)createChildControllers {
    self.firstController = [DemoChildViewController new];
    self.firstController.index = 1;
    self.secondController = [DemoChildViewController new];
    self.secondController.index = 2;
    self.thirdController = [DemoChildViewController new];
    self.thirdController.index = 3;
}

- (void)createHeadView {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 100)];
    header.backgroundColor = [UIColor redColor];
    self.headerView = header;
}

- (void)createSegementControl {
    self.segmentedControl = [[KTVSegmentedControl alloc] initWithTitles:@[@"第一页", @"第二页", @"第三页"]];
    [self.segmentedControl setBackgroundColor:[UIColor grayColor]];
    [self.segmentedControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];

}

#pragma mark - KTVPageViewControllerDataSource
- (NSInteger)numberOfItemsInPageViewController:(KTVPageViewController *)controller {
    return 3;
}

- (NSString *)pageViewController:(KTVPageViewController *)controller scrollViewKeyPathAtIndex:(NSInteger)index {
    return @"tableView";
}

- (UIViewController *)pageViewController:(KTVPageViewController *)controller viewControllerAtIndex:(NSInteger)index {
    if (index == 0) {
        return self.firstController;
    } else if (index == 1) {
        return self.secondController;
    } else {
        return self.thirdController;
    }
}

- (BOOL)isHideNavigationBar:(KTVPageViewController *)controller {
    return NO;
}
- (UIView *)headViewOfpageViewController:(KTVPageViewController *)controller {
    return self.headerView;
}

- (UIViewController *)headViewControllerOfpageViewController:(KTVPageViewController *)controller {
    return nil;
}

- (UIView<KTVHorizontalScrollSegmentedControlProtoclol> *)segmentControlOfpageViewController:(KTVPageViewController *)controller {
    return self.segmentedControl;
}

#pragma mark - KTVPageViewControllerDelegate
- (void)showingChildViewControllerDidChange {
    
}

#pragma mark - KTVSegmentedControl
- (void)segmentControlChanged:(KTVSegmentedControl *)segmentedControl {
    [self showPageAtIndex:segmentedControl.selectedSegmentIndex animated:YES];
}
@end
