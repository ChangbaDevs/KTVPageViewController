//
//  KTVHorizontalScrollContainerScrollView.m
//  KTVDemos
//
//  Created by YinXuebin on 2017/4/5.
//  Copyright © 2017年 guixin. All rights reserved.
//

#import "KTVHorizontalScrollContainerScrollView.h"

@interface KTVHorizontalScrollContainerScrollView()

@end


@implementation KTVHorizontalScrollContainerScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) {
            return YES;
        }
    }
    return NO;
}

@end
