//
//  KTVHorizontalScrollContainerSubViewControllerData.m
//  KTVPageViewController
//
//  Created by yaoyingtao on 2019/1/2.
//  Copyright © 2019 yaoyingtao. All rights reserved.
//

#import "KTVHorizontalScrollContainerSubViewControllerData.h"

@implementation KTVHorizontalScrollContainerSubViewControllerData

+ (instancetype)dataWithViewController:(UIViewController *)viewController scrollViewKeyPath:(NSString *)scrollViewKeyPath {
    KTVHorizontalScrollContainerSubViewControllerData *data = [[KTVHorizontalScrollContainerSubViewControllerData alloc] init];
    if (data) {
        data.viewController = viewController;
        data.scrollViewKeyPath = scrollViewKeyPath;
        data.originInsetTop = 0;
    }
    return data;
}

- (UIScrollView *)scrollView {
    return [self.viewController valueForKeyPath:self.scrollViewKeyPath];
}

@end
