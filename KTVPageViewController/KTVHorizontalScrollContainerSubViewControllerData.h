//
//  KTVHorizontalScrollContainerSubViewControllerData.h
//  KTVPageViewController
//
//  Created by yaoyingtao on 2019/1/2.
//  Copyright © 2019 yaoyingtao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 放到KTVHorizontalScrollConatiner中的segmentControl需要实现改Protocol
 */
@protocol KTVHorizontalScrollSegmentedControlProtoclol <NSObject>

@optional
- (void)containerDidHorizontalScrollWithPage:(CGFloat)pageIndex;

@end

@interface KTVHorizontalScrollContainerSubViewControllerData : NSObject
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSString *scrollViewKeyPath;
@property (nonatomic, assign) CGFloat originInsetTop;
@property (nonatomic, readonly) UIScrollView *scrollView;

/**
 Model的静态构造函数
 
 @param viewController childViewController实例
 @param scrollViewKeyPath childViewController的ScrollView实例的KeyPath
 @return Model实例
 */
+ (instancetype)dataWithViewController:(UIViewController *)viewController scrollViewKeyPath:(NSString *)scrollViewKeyPath;

@end

NS_ASSUME_NONNULL_END
