//
//  UIScrollView+PageController.h
//  ktv
//
//  Created by yaoyingtao on 2018/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (PageController)
@property (nonatomic, weak) UIScrollView *upScrollView;

- (BOOL)isInPageDragging;
@end

NS_ASSUME_NONNULL_END
