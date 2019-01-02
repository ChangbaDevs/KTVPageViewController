//
//  KTVPageViewController.h
//  ktv
//
//  Created by tomy yao on 2018/1/16.
//

#import <UIKit/UIKit.h>
#import "KTVHorizontalScrollContainerSubViewControllerData.h"
#import "KTVHorizontalScrollContainerScrollView.h"


/*
 使用注意事项：
 1、如果使用的是KTVTableview或者SimpleTableviewController，需要将tabelview的isInPageViewController设置，并且是是在[super viewdidload]之前
 2、 如果想在subcontroller的viewdidload中使用tableview的contentoffset，例如进行loading展示，
     需要在viewdidload之前创建好tableview（不能使用xib创建talbview），并且设置好footerview，否则contentoffset不准确。
 */

@protocol KTVPageViewControllerDataSource;
@protocol KTVPageViewControllerDelegate;

@interface KTVPageViewController : UIViewController
@property (nonatomic, weak) id <KTVPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <KTVPageViewControllerDelegate> delegate;

/**
 当前显示的childViewController的index
 如果在滑动过程中，则返回显示面积大的页面index。（通过contentOffset／width四舍五入实现）
 */
@property (nonatomic, assign, readonly) NSUInteger currentChildViewControllerIndex;
@property (nonatomic, strong, readonly) UIScrollView *currentScrollView;
@property (nonatomic, strong, readonly) UIViewController *currentViewController;

//横划是否需要动画
@property (nonatomic, assign) BOOL needScrollAnimation;

@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) BOOL containerCanScroll;

- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)reloadHeadView;

- (void)resetChildData:(KTVHorizontalScrollContainerSubViewControllerData *)data atIndex:(NSUInteger)index;
@end


@protocol KTVPageViewControllerDelegate <NSObject>
@optional
- (void)showingChildViewControllerDidChange;
- (void)showingChildViewControllerWillChangeFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
@end

@protocol KTVPageViewControllerDataSource <NSObject>
@required
- (NSInteger)numberOfItemsInPageViewController:(KTVPageViewController *)controller;
- (NSString *)pageViewController:(KTVPageViewController *)controller scrollViewKeyPathAtIndex:(NSInteger)index;
- (UIViewController *)pageViewController:(KTVPageViewController *)controller viewControllerAtIndex:(NSInteger)index;

@optional
- (BOOL)isHideNavigationBar:(KTVPageViewController *)controller;
- (UIView *)headViewOfpageViewController:(KTVPageViewController *)controller;
- (UIViewController *)headViewControllerOfpageViewController:(KTVPageViewController *)controller;
- (UIView<KTVHorizontalScrollSegmentedControlProtoclol> *)segmentControlOfpageViewController:(KTVPageViewController *)controller;
@end
