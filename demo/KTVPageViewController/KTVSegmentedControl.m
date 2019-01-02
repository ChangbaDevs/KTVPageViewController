//
//  KTVSegmentedControl.m
//  ktv
//
//  Created by Ke on 8/17/15.
//
//

#import "KTVSegmentedControl.h"

#define KTV_SEGMENTED_CONTROL_HEIGHT 44
#define KTV_SEGMENTED_CONTROL_DEFAULT_WIDTH 80
#define KTV_SEGMENTED_CONTROL_INDICATOR_WIDTH 24
#define KTV_SEGMENTED_CONTROL_INDICATOR_HEIGHT 3


@interface KTVSegmentedControl()
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, strong) UIView *selectedIndicator;
@end

@implementation KTVSegmentedControl
- (instancetype)initWithTitles:(nullable NSArray<NSString *> *)titles {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), KTV_SEGMENTED_CONTROL_HEIGHT)];
    if (self) {
        self.buttons = [NSMutableArray array];
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat width = MAX(KTV_SEGMENTED_CONTROL_DEFAULT_WIDTH, CGRectGetWidth([[UIScreen mainScreen] bounds]) / [titles count]);
            button.frame = CGRectMake(width * idx, 0, width, KTV_SEGMENTED_CONTROL_HEIGHT);
            button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.buttons addObject:button];
        }];
        
        _selectedIndicator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.buttons[0].frame), KTV_SEGMENTED_CONTROL_HEIGHT - KTV_SEGMENTED_CONTROL_INDICATOR_HEIGHT - 0.5, KTV_SEGMENTED_CONTROL_INDICATOR_WIDTH, KTV_SEGMENTED_CONTROL_INDICATOR_HEIGHT)];
        _selectedIndicator.layer.cornerRadius = KTV_SEGMENTED_CONTROL_INDICATOR_HEIGHT/2.0;
        _selectedIndicator.layer.masksToBounds = YES;
        [self addSubview:_selectedIndicator];
        
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - .5, self.bounds.size.width, .5)];
        bottom.backgroundColor = [UIColor colorWithRed:0xee/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1.0f];
        [self addSubview:bottom];
        [self setTintColor:[UIColor colorWithRed:0xff/255.0 green:0x50/255.0 blue:0x46/255.0 alpha:1.0f]];
    }
    return self;
}

- (void)setAttributedTitle:(nullable NSAttributedString *)title forSegmentAtIndex:(NSUInteger)segment {
    if (segment < [self.buttons count]) {
        UIButton *button = self.buttons[segment];
        UIColor *color = (segment == self.selectedSegmentIndex) ? self.tintColor : [UIColor colorWithRed:0x12 green:0x12 blue:0x12 alpha:1.0f];
        NSMutableAttributedString *theTitle = [[NSMutableAttributedString alloc] initWithAttributedString:title];
        [theTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, title.length)];
        [button setAttributedTitle:theTitle forState:UIControlStateNormal];
//        [self updateButtonColors];
    }
}

- (void)setTitle:(nullable NSString *)title forSegmentAtIndex:(NSUInteger)segment {
    if (segment < [self.buttons count]) {
        UIButton *button = self.buttons[segment];
        [button setTitle:title forState:UIControlStateNormal];
        UIColor *color = (segment == self.selectedSegmentIndex) ? self.tintColor : [UIColor colorWithRed:0x12 green:0x12 blue:0x12 alpha:1.0f];
        [button setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self updateButtonColors];
    self.selectedIndicator.backgroundColor = tintColor;
}

- (void)updateButtonColors {
    for (NSUInteger i = 0; i < [self.buttons count]; i++) {
        UIButton *button = self.buttons[i];
        UIColor *color = (i == self.selectedSegmentIndex) ? self.tintColor : [UIColor colorWithRed:0x12/255.0 green:0x12/255.0 blue:0x12/255.0 alpha:1.0f];
        [button setTitleColor:color forState:UIControlStateNormal];
        
        NSMutableAttributedString *title = [[button attributedTitleForState:UIControlStateNormal] mutableCopy];
        if (title) {
            [title addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, title.length)];
            [button setAttributedTitle:title forState:UIControlStateNormal];
        }
    }
}

- (void)buttonTapped:(UIButton *)sender {
    for (NSUInteger i = 0; i < [self.buttons count]; i++) {
        UIButton *button = self.buttons[i];
        if (button == sender) {
            self.selectedSegmentIndex = i;
        }
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    if (selectedSegmentIndex < [self.buttons count]) {
        _beforeSelectedSegmentIndex = _selectedSegmentIndex;
        _selectedSegmentIndex = selectedSegmentIndex;
        [self updateButtonColors];
        [self animateIndicatorToIndex:selectedSegmentIndex];
    }
}

- (void)animateIndicatorToIndex:(NSUInteger)index {
    [UIView animateWithDuration:.5f
                          delay:.0f
         usingSpringWithDamping:.7f
          initialSpringVelocity:.1f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        UIButton *button = self.buttons[index];
        CGRect indicatorFrame = self.selectedIndicator.frame;
        indicatorFrame.origin.x = CGRectGetMidX(button.frame) - indicatorFrame.size.width/2;
        self.selectedIndicator.frame = indicatorFrame;
    } completion:nil];
}

- (void)showBadgeAtIndex:(NSUInteger)segment {

}

- (void)hideBadgeAtIndex:(NSUInteger)segment {

}

#pragma mark - KTVHorizontalScorllSegmentedControlProtoclol
- (void)containerDidHorizontalScrollWithPage:(CGFloat)pageIndex {
    self.selectedSegmentIndex = pageIndex;
}

@end
