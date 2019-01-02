//
//  KTVPageUpScrollView.m
//  ktv
//
//  Created by yaoyingtao on 2018/12/11.
//

#import "KTVPageUpScrollView.h"

@interface KTVPageUpScrollView () <UIGestureRecognizerDelegate>

@end

@implementation KTVPageUpScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.panGestureRecognizer.delegate = self;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitedView = [super hitTest:point withEvent:event];
    if (hitedView == self) {
        return nil;
    } else {
        return hitedView;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
