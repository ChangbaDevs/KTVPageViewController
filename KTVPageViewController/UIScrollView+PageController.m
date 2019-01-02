//
//  UIScrollView+PageController.m
//  ktv
//
//  Created by yaoyingtao on 2018/12/20.
//

#import "UIScrollView+PageController.h"
#import <objc/runtime.h>

@implementation UIScrollView (PageController)
- (void)setUpScrollView:(UIScrollView *)upScrollView {
    objc_setAssociatedObject(self, @selector(upScrollView), upScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)upScrollView {
    return objc_getAssociatedObject(self, @selector(upScrollView));
}

- (BOOL)isInPageDragging {
    if (!self.upScrollView) {
        return self.dragging;
    } else {
        return self.dragging || self.upScrollView.dragging;
    }
}
@end
