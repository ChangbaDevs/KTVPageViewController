# KTVPageViewController
KTVPageViewController is a horizontal scroll view controller

##  Installation
### Installation with CocoaPods
To integrate KTVPageViewController into your Xcode project using CocoaPods, specify it in your Podfile:

```
pod 'KTVPageViewController', '~> 1.0.0'
```
### Installation with Carthage
To integrate into your Xcode project using Carthage, specify it in your Cartfile:


```
github "ChangbaDevs/KTVPageViewController" ~> 1.0.0
```
Run carthage update to build the framework and drag the built KTVPageViewController.framework into your Xcode project.

## Usage
KTVPageViewController is meant to be subclassed, like you would normally do with UITableViewController.
### dataSource

```objc
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

```

### delegate

```objc
@protocol KTVPageViewControllerDelegate <NSObject>
@optional
- (void)showingChildViewControllerDidChange;
- (void)showingChildViewControllerWillChangeFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
@end
```

## License
KTVPageViewController is released under the MIT license.

## Related articles


