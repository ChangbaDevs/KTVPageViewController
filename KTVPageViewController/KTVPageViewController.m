//
//  KTVPageViewController.m
//  ktv
//
//  Created by tomy yao on 2018/1/16.
//

#import "KTVPageViewController.h"
#import "KTVPageUpScrollView.h"
#import "UIScrollView+PageController.h"

#define ScreenSize [UIScreen mainScreen].bounds.size
#ifndef IS_IPHONE_X
#define IS_IPHONE_X ([UIScreen mainScreen].bounds.size.height >= 812)
#endif

#define NavigatinBarHeight (IS_IPHONE_X ? 88 : 64)


@interface KTVPageViewController ()
@property (nonatomic, strong) KTVHorizontalScrollContainerScrollView *containerScrollView;
@property (nonatomic, strong) KTVPageUpScrollView *upScrollView;
@property (nonatomic, strong) NSMutableSet<KTVHorizontalScrollContainerSubViewControllerData *> *loadedViewControllerDatas;
@property (nonatomic, weak) UIScrollView *observingScrollView;
@property (nonatomic, assign) BOOL hasScrolled;
@property (nonatomic, assign) BOOL isHorizontalAnimating;
@property (assign, nonatomic) BOOL isHideNavigationBar;



/**
 跟随每个ChildViewController的ScrollView纵向滚动的HeaderView
 */
@property (nonatomic, strong) UIView *pageHeaderView;


/**
 跟随每个ChildViewController的ScrollView纵向滚动的HeaderViewController
 注意：设置这个属性并不会自动设置headerView属性
 */
@property (nonatomic, strong) UIViewController *headerViewController;

/**
 顶部悬停的segmentController
 */
@property (nonatomic, strong) UIView<KTVHorizontalScrollSegmentedControlProtoclol> *pageSegmentedControl;

/**
 childViewController的描述Model数组。参考KTVHorizontalScorllContainerSubViewControllerData
 */
@property (nonatomic, strong) NSMutableArray<KTVHorizontalScrollContainerSubViewControllerData*> *childViewControllerDatas;
@property (nonatomic, assign) NSInteger showingChildViewControllerIndex;             //为了避免重复调用showingChildViewControllerDidChange
@property (nonatomic, assign) BOOL canSendContainerDidScroll;                        //如果是手动设置currentChildViewControllerIndex,
@property (nonatomic, assign) BOOL isInitComplete;                        //如果是手动设置currentChildViewControllerIndex,
@property (nonatomic, assign) CGPoint headerLastPoint;

@property (nonatomic, assign) BOOL isUpScroll;
@property (nonatomic, assign) BOOL isDownScroll;

@end

@implementation KTVPageViewController
#pragma mark - life cycle
- (void)dealloc {
    [self.containerScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.observingScrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.upScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.frame = [UIScreen mainScreen].bounds;
    self.loadedViewControllerDatas = [[NSMutableSet alloc] init];
    self.showingChildViewControllerIndex = -1;
    self.canSendContainerDidScroll = YES;
    self.needScrollAnimation = YES;
    [self createContainerScrollView];
    [self createUpContainerView];
    self.isDownScroll = YES;
}

- (void)createContainerScrollView {
    self.containerScrollView = [[KTVHorizontalScrollContainerScrollView alloc] initWithFrame:self.view.bounds];
    self.containerScrollView.bounces = NO;
    self.containerScrollView.scrollsToTop = NO;
    self.containerScrollView.showsVerticalScrollIndicator = NO;
    self.containerScrollView.showsHorizontalScrollIndicator = NO;
    self.containerScrollView.pagingEnabled = YES;
    self.containerScrollView.directionalLockEnabled = YES;
    [self.view addSubview:self.containerScrollView];
    
    [self.containerScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)createUpContainerView {
    self.upScrollView = [[KTVPageUpScrollView alloc] initWithFrame:self.view.bounds];
    self.upScrollView.showsVerticalScrollIndicator = NO;
    self.upScrollView.showsHorizontalScrollIndicator = NO;
    self.upScrollView.directionalLockEnabled = YES;
    self.upScrollView.contentSize = CGSizeMake(ScreenSize.width, ScreenSize.height);
    self.upScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.upScrollView];
    
    if (@available(iOS 11.0, *)) {
        self.upScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.upScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - getter
- (NSUInteger)currentChildViewControllerIndex {
    return round(self.containerScrollView.contentOffset.x / self.view.bounds.size.width);
}

- (UIScrollView *)currentScrollView {
    return self.childViewControllerDatas[self.currentChildViewControllerIndex].scrollView;
}

- (UIViewController *)currentViewController {
    return self.childViewControllerDatas[self.currentChildViewControllerIndex].viewController;
}

#pragma mark - setter
- (void)setCurrentChildViewControllerIndex:(NSUInteger)currentChildViewControllerIndex {
    _canSendContainerDidScroll = NO;
    [self.containerScrollView setContentOffset:CGPointMake(currentChildViewControllerIndex *self.view.bounds.size.width, 0) animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_canSendContainerDidScroll = YES;
    });
}

- (void)setDataSource:(id<KTVPageViewControllerDataSource>)dataSource {
    _dataSource = dataSource;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

- (void)setPageSegmentedControl:(UIView<KTVHorizontalScrollSegmentedControlProtoclol> *)segmentedControl {
    [_pageSegmentedControl removeFromSuperview];
    _pageSegmentedControl = segmentedControl;
    CGRect segmentFrame = segmentedControl.frame;
    segmentFrame.size.width = self.containerScrollView.bounds.size.width;
    segmentFrame.origin.y = self.pageHeaderView.bounds.size.height;
    segmentedControl.frame = segmentFrame;
    [self.upScrollView addSubview:segmentedControl];
    [self reloadHeaderAndSegmentControl];
}

- (void)setPageHeaderView:(UIView *)headerView {
    [_pageHeaderView removeFromSuperview];
    _pageHeaderView = headerView;
    
    CGRect headerFrame = headerView.frame;
    headerFrame.size.width = self.containerScrollView.bounds.size.width;
    headerView.frame = headerFrame;
    [self.upScrollView addSubview:headerView];
    if (self.headerViewController) {
        [self addChildViewController:self.headerViewController];
    }
    [self reloadHeaderAndSegmentControl];
}

- (void)setStartIndex:(NSInteger)startIndex {
    _startIndex = startIndex;
    if (self.childViewControllerDatas) {
        if (startIndex >= self.childViewControllerDatas.count) {
            startIndex = 0;
        }
        [self showPageAtIndex:startIndex animated:NO];
    }
}

- (void)setContainerCanScroll:(BOOL)containerCanScroll {
    _containerCanScroll = containerCanScroll;
    self.containerScrollView.scrollEnabled = containerCanScroll;
}

- (void)loadData {
    if (self.childViewControllerDatas) {
        return;
    }
    
    self.childViewControllerDatas = [NSMutableArray array];
    NSInteger itemNumber = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInPageViewController:)]) {
        itemNumber = [self.dataSource numberOfItemsInPageViewController:self];
    }
    
    for (NSInteger i = 0; i < itemNumber; i++) {
        KTVHorizontalScrollContainerSubViewControllerData *data = [[KTVHorizontalScrollContainerSubViewControllerData alloc] init];
        data.scrollViewKeyPath = [self.dataSource pageViewController:self scrollViewKeyPathAtIndex:i];
        
        data.viewController = [self.dataSource pageViewController:self viewControllerAtIndex:i];
        [self.childViewControllerDatas addObject:data];
    }
    
    if ([self.dataSource respondsToSelector:@selector(headViewControllerOfpageViewController:)]) {
        self.headerViewController = [self.dataSource headViewControllerOfpageViewController:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(headViewOfpageViewController:)]) {
        UIView *headView = [self.dataSource headViewOfpageViewController:self];
        CGRect headerFrame = headView.frame;
        headerFrame.size.width = ScreenSize.width;
        headView.frame = headerFrame;
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, headView.bounds.size.height)];
        containerView.backgroundColor = [UIColor clearColor];
        [containerView addSubview:headView];
        self.pageHeaderView = containerView;
    }
    
    if ([self.dataSource respondsToSelector:@selector(segmentControlOfpageViewController:)]) {
        self.pageSegmentedControl = [self.dataSource segmentControlOfpageViewController:self];
    }
    
    self.containerScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * self.childViewControllerDatas.count, self.view.bounds.size.height);
    //先做偏移，否则，currentindex不对,多偏移1为了kvo被处发
    if (self.startIndex >= itemNumber) {
        self.startIndex = 0;
    }
    //offset不会变化，不会出发kvo进行加载，所以先偏移
    [self.containerScrollView setContentOffset:CGPointMake(self.startIndex * CGRectGetWidth(self.view.bounds) + 1, 0) animated:NO];
    self.isInitComplete = YES;
    [self showPageAtIndex:self.startIndex animated:NO];
}


#pragma mark - Horizontal scroll
- (void)loadChildViewControllerWithIndex:(NSUInteger)index {
    if ((NSInteger)index > (NSInteger)self.childViewControllerDatas.count - 1 ||
        [self.loadedViewControllerDatas containsObject:self.childViewControllerDatas[index]]) {
        return;
    }
    
    KTVHorizontalScrollContainerSubViewControllerData *data = self.childViewControllerDatas[index];

    [self.loadedViewControllerDatas addObject:data];
    data.viewController.view.frame = CGRectMake(index * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    //下拉刷新需要
    data.scrollView.upScrollView = self.upScrollView;
    [self.containerScrollView addSubview:data.viewController.view];
    [self addChildViewController:data.viewController];
    [self adjustChildDataContentInset:data];
}

- (void)adjustChildDataContentInset:(KTVHorizontalScrollContainerSubViewControllerData*)data {
    BOOL isHideNavigationBar = YES;
    if ([self.dataSource respondsToSelector:@selector(isHideNavigationBar:)]) {
        isHideNavigationBar = [self.dataSource isHideNavigationBar:self];
    }
    self.isHideNavigationBar = isHideNavigationBar;
    //防止data.scrollView为nil，先调用data.viewController.view，触发viewdidload去创建
    if (!data.scrollView) {
        CGRectGetWidth(data.viewController.view.bounds);
    }
    
    BOOL isAutoAdjust = NO;
    //如果不需要隐藏导航栏，需要将autoadjust修改为no，同时修改contentinset
    if (!isHideNavigationBar) {
        if (@available(iOS 11.0, *)) {
            if (data.scrollView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
                data.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
                isAutoAdjust = YES;
            }
        } else {
            if (data.viewController.automaticallyAdjustsScrollViewInsets) {
                isAutoAdjust = YES;
                data.viewController.automaticallyAdjustsScrollViewInsets = NO;
            }
        }
    }
    
    if (isAutoAdjust) {
        data.originInsetTop = NavigatinBarHeight;
    } else {
        data.originInsetTop = data.scrollView.contentInset.top;
    }
    UIEdgeInsets contentInset = data.scrollView.contentInset;
    contentInset.top = self.pageHeaderView.bounds.size.height + self.pageSegmentedControl.bounds.size.height + data.originInsetTop;
    data.scrollView.contentInset = contentInset;
    data.scrollView.contentOffset = CGPointMake(0, -contentInset.top);
}

- (void)resetObservingScrollView {
    if ((NSInteger)self.currentChildViewControllerIndex > (NSInteger)self.childViewControllerDatas.count -1) {
        return;
    }
    [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.observingScrollView removeObserver:self forKeyPath:@"contentSize"];
    
    self.observingScrollView = self.currentScrollView;
    [self.observingScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.observingScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    //修改contensize会导致contentoffset回调
    self.isUpScroll = NO;
    CGSize contentSize = self.currentScrollView.contentSize;
    contentSize.height += self.pageHeaderView.bounds.size.height + self.pageSegmentedControl.bounds.size.height;
    CGPoint contentOffset = self.upScrollView.contentOffset;
    self.upScrollView.contentSize = contentSize;
    UIEdgeInsets contentInset = self.currentScrollView.contentInset;
    contentInset.top = contentInset.top - self.pageHeaderView.bounds.size.height - self.pageSegmentedControl.bounds.size.height;
    self.upScrollView.contentInset =contentInset;
    self.upScrollView.contentOffset = contentOffset;
    self.isUpScroll = YES;

}

//当header或segmentcontrol修改时，需要重新计算contentinset，和下拉刷新的位置
- (void)reloadHeaderAndSegmentControl {
    for (KTVHorizontalScrollContainerSubViewControllerData *data in self.childViewControllerDatas) {
        if ([self.loadedViewControllerDatas containsObject:data]) {
            UIEdgeInsets contentInset = data.scrollView.contentInset;
            CGPoint contentOffset = data.scrollView.contentOffset;
            CGFloat newTop = self.pageHeaderView.bounds.size.height + self.pageSegmentedControl.bounds.size.height + data.originInsetTop;
            if (newTop - contentInset.top != 0) {
                contentOffset.y -= newTop - contentInset.top;
            }
            contentInset.top = newTop;
            data.scrollView.contentInset = contentInset;
            data.scrollView.contentOffset = contentOffset;
        }
    }
    [self refreshHeaderViewPosition];
    [self refreshSegmentControlPosition];
//    [self changeRefreshViewOriginTop];
}

//- (void)changeRefreshViewOriginTop {
//    UIScrollView *scrollView = self.currentScrollView;
//    for (UIView *subView in scrollView.subviews) {
//        if ([subView isKindOfClass:[KTVRefreshView class]]) {
//            [(KTVRefreshView*)subView setOriginalTopInset:scrollView.contentInset.top];
//        }
//        if ([subView isKindOfClass:[KTVGradientRefreshView class]]) {
//            [(KTVGradientRefreshView*)subView setOriginalTopInset:scrollView.contentInset.top];
//        }
//    }
//}


#pragma mark - Vertiacl scroll

/**
 childViewController之前的contentOffset同步的规则：
 1、如果当前childVC已经露出了header，其他的childVC也需要和当前的contentOffset相等
 2、如果当前childVC把header划出了，其他露出header的childVC滚到刚刚划出header，没露出header的childVC保持原来的contentOffset不变
 */
- (void)synchronizeAllSubScrollViewOffset {
    if (!self.pageHeaderView) {
        return;
    }
    UIScrollView *currentScrollView = self.childViewControllerDatas[self.currentChildViewControllerIndex].scrollView;
    CGPoint contentOffset = currentScrollView.contentOffset;
    
    for (KTVHorizontalScrollContainerSubViewControllerData *data in self.loadedViewControllerDatas) {
        if (data.scrollView == currentScrollView) {
            continue;
        }
        CGFloat naivgationHeight = self.isHideNavigationBar ? 0 : NavigatinBarHeight;
        if (contentOffset.y < -self.pageSegmentedControl.bounds.size.height - naivgationHeight) {
            ;            data.scrollView.contentOffset = contentOffset;
        } else if (data.scrollView.contentOffset.y < -self.pageSegmentedControl.bounds.size.height - naivgationHeight) {
            data.scrollView.contentOffset = CGPointMake(0, -self.pageSegmentedControl.bounds.size.height - naivgationHeight);
        }
    }
}

- (void)refreshHeaderViewPosition {
    if (!self.currentScrollView) {
        return;
    }
    self.isUpScroll = NO;
    CGPoint offset = self.currentScrollView.contentOffset;
    offset.y = offset.y + self.pageSegmentedControl.bounds.size.height + self.pageHeaderView.bounds.size.height;
    self.upScrollView.contentOffset = offset;
    self.isUpScroll = YES;
}

- (void)refreshSegmentControlPosition {
    CGFloat delta = NavigatinBarHeight;
    CGRect pageSegmentedFrame = self.pageSegmentedControl.frame;
    if (self.upScrollView.contentOffset.y > self.pageHeaderView.bounds.size.height - delta) {
        pageSegmentedFrame.origin.y = self.upScrollView.contentOffset.y + delta;
    } else {
        pageSegmentedFrame.origin.y = self.pageHeaderView.bounds.size.height;
    }
    self.pageSegmentedControl.frame = pageSegmentedFrame;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (object == self.containerScrollView) {
            //横划
            if (!self.isInitComplete) {
                return;
            }
            //根据当前的滑动位置，决定需要加载的childViewController
            CGFloat pageIndex = fabs(self.containerScrollView.contentOffset.x / self.containerScrollView.bounds.size.width);
            [self loadChildViewControllerWithIndex:ceil(pageIndex)];
            [self loadChildViewControllerWithIndex:floor(pageIndex)];
            
            [self synchronizeAllSubScrollViewOffset];
            [self refreshHeaderViewPosition];
            [self refreshSegmentControlPosition];
            
            //通知segmentControl横向发生了移动，让segmentControl重置选中线的位置
            if (_canSendContainerDidScroll && [self.pageSegmentedControl respondsToSelector:@selector(containerDidHorizontalScrollWithPage:)]) {
                [self.pageSegmentedControl containerDidHorizontalScrollWithPage:self.containerScrollView.contentOffset.x / self.containerScrollView.bounds.size.width];
            }
            
            //当滑动到整页时，需要把header/segmentControl塞到childViewController的ScrollView里面
            //当滑动到不是整页的时候，需要把header/segmentControl从childViewController的ScrollView里面拿出来，保持位于屏幕顶端
            if ((int)(self.containerScrollView.contentOffset.x)%(int)(self.view.bounds.size.width) == 0) {
                [self resetObservingScrollView];
//                [self changeRefreshViewOriginTop];
                if (self.showingChildViewControllerIndex != self.currentChildViewControllerIndex) {
                    if ([self.delegate respondsToSelector:@selector(showingChildViewControllerDidChange)]) {
                        [self.delegate showingChildViewControllerDidChange];
                    }
                    _showingChildViewControllerIndex = self.currentChildViewControllerIndex;
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(showingChildViewControllerWillChangeFromIndex:toIndex:)]) {
                    NSUInteger floorIndex = floor(self.containerScrollView.contentOffset.x / self.containerScrollView.bounds.size.width);
                    NSUInteger ceilIndex = ceil(self.containerScrollView.contentOffset.x / self.containerScrollView.bounds.size.width);
                    NSUInteger curIndex = self.currentChildViewControllerIndex;
                    [self.delegate showingChildViewControllerWillChangeFromIndex:curIndex
                                                                         toIndex:floorIndex==curIndex? ceilIndex: floorIndex];
                }
            }
        } else if (object == self.upScrollView) {
            //有的时候，这个会被莫名其妙的回调，导致错误,如果没有header就不处理，segementcontrol也不能滑动
            if (self.pageHeaderView.bounds.size.height > 0) {
                //header或segment滑动
                if (self.isUpScroll) {
                    self.isDownScroll = NO;
                    CGPoint offset = self.upScrollView.contentOffset;
                    offset.y = offset.y - self.pageHeaderView.bounds.size.height - self.pageSegmentedControl.bounds.size.height;
                    self.currentScrollView.contentOffset = offset;
                    [self refreshSegmentControlPosition];
                    self.isDownScroll = YES;
                }
            } else {
                [self refreshSegmentControlPosition];
            }
        } else if (object == self.currentScrollView) {
            //subcontroller滑动
            if (self.isDownScroll) {
                self.isUpScroll = NO;
                self.upScrollView.scrollEnabled = NO;
                self.upScrollView.scrollEnabled = YES;
                [self refreshHeaderViewPosition];
                [self refreshSegmentControlPosition];
                [self synchronizeAllSubScrollViewOffset];
                self.isUpScroll = YES;
            }
        }
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        //修改upscrollview的contentsize
        if (object == self.currentScrollView) {
            self.isUpScroll = NO;
            CGSize contentSize = self.currentScrollView.contentSize;
            contentSize.height += self.pageHeaderView.bounds.size.height + self.pageSegmentedControl.bounds.size.height;
            CGPoint contentOffset = self.upScrollView.contentOffset;
            self.upScrollView.contentSize = contentSize;
            self.upScrollView.contentOffset = contentOffset;
            self.isUpScroll = YES;
        }
    }
}

#pragma mark - public
- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated {
    self.pageSegmentedControl.userInteractionEnabled = NO;
    _canSendContainerDidScroll = NO;
    [self.containerScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.bounds) * index, 0) animated:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pageSegmentedControl containerDidHorizontalScrollWithPage:index];
        self->_canSendContainerDidScroll = YES;
        self.pageSegmentedControl.userInteractionEnabled = YES;
    });
}

- (void)reloadHeadView {
    if ([self.dataSource respondsToSelector:@selector(headViewControllerOfpageViewController:)]) {
        self.headerViewController = [self.dataSource headViewControllerOfpageViewController:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(headViewOfpageViewController:)]) {
        UIView *headView = [self.dataSource headViewOfpageViewController:self];
        CGRect headFrame = headView.frame;
        headFrame.size.width = ScreenSize.width;
        headView.frame = headFrame;
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenSize.width, headView.bounds.size.width)];
        containerView.backgroundColor = [UIColor clearColor];
        [containerView addSubview:headView];
        self.pageHeaderView = containerView;
    }
}

- (void)resetChildData:(KTVHorizontalScrollContainerSubViewControllerData *)data atIndex:(NSUInteger)index {
    if (index >= self.childViewControllerDatas.count) {
        return;
    }
    
    [self.childViewControllerDatas replaceObjectAtIndex:index withObject:data];
    [self resetObservingScrollView];
}

@end
