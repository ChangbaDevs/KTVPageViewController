//
//  KTVSegmentedControl.h
//  ktv
//
//  Created by Ke on 8/17/15.
//
//

#import <UIKit/UIKit.h>
#import "KTVHorizontalScrollContainerSubViewControllerData.h"

NS_ASSUME_NONNULL_BEGIN
@interface KTVSegmentedControl : UIControl <KTVHorizontalScrollSegmentedControlProtoclol>

@property (nonatomic, strong, readonly) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, assign, readonly) NSInteger beforeSelectedSegmentIndex;   //前一次segment的选择Index。为了处理需要回退的情况
                                                                                //比如包房跳转到观众时，如果没登录，需要弹提示，退回原来的选择（公聊）

- (instancetype)initWithTitles:(nullable NSArray<NSString *> *)titles;

- (void)setTitle:(nullable NSString *)title forSegmentAtIndex:(NSUInteger)segment;

- (void)setAttributedTitle:(nullable NSAttributedString *)title forSegmentAtIndex:(NSUInteger)segment;

- (void)showBadgeAtIndex:(NSUInteger)segment;

- (void)hideBadgeAtIndex:(NSUInteger)segment;

- (void)containerDidHorizontalScrollWithPage:(CGFloat)pageIndex;
@end
NS_ASSUME_NONNULL_END
