//
//  ZTNavigationMenu.m
//  ZTNavigationMenuDemo
//
//  Created by Cer on 2018/9/27.
//  Copyright © 2018年 Cer. All rights reserved.
//

#import "ZTNavigationMenu.h"
#import "ZTMenuCell.h"
#import "ZTPrefixHeader.pch"
#import <objc/runtime.h>

#define kZTMenuWidthMin 140
#define kZTMenuWidthMax 200
#define kZTCellHeightMin 30
#define kZTCellHeightMax 100
#define kZTContentHeightMin 100
#define kZTContentHeightMax 350
#define kZTEffectAlphaMin 0.1f
#define kZTEffectAlphaMax 1.0f
#define kZTLayoutGuideBottomMin 1
#define kZTLayoutGuideBottomMax 150
#define kZTDefaultTitleFont [UIFont boldSystemFontOfSize:18]
#define kZTDefaultTitleColor kZTColorFromRGB(0x333333)

@interface ZTNavigationMenu ()<UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UIVisualEffectView *effectView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray *tempData;
@property(nonatomic, assign) int tempIndex;
@property(nonatomic, copy) ZTNavigationMenuBlock block;
@property(nonatomic, weak) UIViewController *VC;
@property(nonatomic, assign, getter=isAddToView) BOOL addToView;

@end

@implementation ZTNavigationMenu

+ (instancetype)navigationMenu
{
    return [[self alloc] init];
}

+ (instancetype)navigationMenuWithBlock:(ZTNavigationMenuBlock)block
{
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(ZTNavigationMenuBlock)block
{
    if (self = [self init])
    {
        [self addBlock:block];
    }
    
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _titleFont = kZTDefaultTitleFont;
        _titleColor = kZTDefaultTitleColor;
        _effectStyle = UIBlurEffectStyleLight;
        _style = ZTBackgroundStyleTranslucent;
        _tapBackgroundHidden = YES;
        _rotate = YES;
        _tempIndex = -1;
        _index = -1;
        _menuWidth = 140;
        _cellHeight = 50;
        _contentHeight = 200;
        _layoutGuideBottom = 0;
        _effectAlpha = 0.8f;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self addTarget:self action:@selector(tapCall) forControlEvents:UIControlEventTouchUpInside];
        [self createView];
    }
    
    return self;
}

//- (void)dealloc
//{
//    NSLog(@"navigationMenu 销毁");
//
//    return;
//}

+ (BOOL)accessInstanceVariablesDirectly
{
    return NO;
}

+ (void)load
{
    [self exchangeMethod];
    
    return;
}

#pragma mark - 方法交换
+ (void)exchangeMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = self;
        SEL originalSelector = @selector(removeFromSuperview);
        SEL swizzledSelector = @selector(ex_removeFromSuperview);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // 交换方法实现
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod)
        {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }
        else
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
    
    return;
}

- (void)ex_removeFromSuperview
{
    if ([self superview] != nil)
    {
        if ([self VC] != [self getCurrentVC])
        {
            [self ex_removeFromSuperview];
        }
    }
    
    return;
}

#pragma mark - 更新UI
- (void)didMoveToSuperview
{
    if ([self isAddToView])
    {
        return;
    }
    
    [self setAddToView:YES];
    [self setVC:[self getCurrentVC]];
    [self updateMenuWidth];
    [self createMenuView];
    [self setData:[self tempData]];
    [self updateIndex:[self tempIndex]];
    [self setTempData:nil];
    
    return;
}

- (void)updateMenuWidth
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11)
    {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            [make size].mas_equalTo(CGSizeMake([self menuWidth], 44));
        }];
    }
    else
    {
        CGRect frame = [self frame];
        CGFloat width = frame.size.width;
        CGFloat x = ([self menuWidth] - width) / 2;
        frame.size = CGSizeMake([self menuWidth], 44);
        frame.origin.x -= x;
        [self setFrame:frame];
    }
    
    [self layoutIfNeeded];
    
    return;
}

#pragma mark - 工具方法
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC = nil;
    
    if ([rootVC presentedViewController])
    {
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]])
    {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    }
    else if ([rootVC isKindOfClass:[UINavigationController class]])
    {
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    }
    else
    {
        currentVC = rootVC;
    }
    
    return currentVC;
}

- (BOOL)isShowBar
{
    UIViewController *VC = [self VC];
    UINavigationController *navigationController = [VC navigationController];
    if (navigationController != nil && [navigationController isToolbarHidden] == NO)
    {
        return YES;
    }
    
    id app = [[UIApplication sharedApplication] delegate];
    for (UIView *sub in [[app window] subviews])
    {
        for (UIView *sub2 in [sub subviews])
        {
//            NSLog(@"%@", sub2);
            if ([sub2 isKindOfClass:[UITabBar class]])
            {
                if ([sub2 isHidden] == NO)
                {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

#pragma mark - 创建view
- (void)createView
{
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[self titleFont]];
    [titleLabel setTextColor:[self titleColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:titleLabel];
    [self setTitleLabel:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        [make height].mas_equalTo(30);
        [make center].equalTo(self);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setImage:[UIImage imageNamed:@"ZTNavigationMenu_arrow"]];
    [imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:imageView];
    [self setImageView:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        [make size].mas_equalTo(CGSizeMake(14, 14));
        [make centerY].equalTo(titleLabel);
        [make leading].equalTo([titleLabel mas_trailing]).offset(5);
    }];
    
    return;
}

- (void)createMenuView
{
    UIViewController *VC = [self VC];
    UIView *view = [VC view];
    
    MASViewAttribute *bottom = [VC mas_bottomLayoutGuideBottom];
    CGFloat offset = 0;
    if ([self layoutGuideBottom] > 0)
    {
        offset = [self layoutGuideBottom];
    }
    else
    {
        if ([self isShowBar])
        {
            bottom = [VC mas_bottomLayoutGuideTop];
        }
    }
    
    // 背景view
    UIView *backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    [backgroundView setHidden:YES];
    [view addSubview:backgroundView];
    [self setBackgroundView:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        [[make trailing] leading].equalTo(view);
        [make top].equalTo([VC mas_topLayoutGuideBottom]);
        [make bottom].equalTo(bottom).offset(-offset);
    }];
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] init]; // 模糊层
    [effectView setAlpha:[self effectAlpha]];
    [effectView setUserInteractionEnabled:YES];
    [effectView setBackgroundColor:[UIColor clearColor]];
    [backgroundView addSubview:effectView]; // 给view加个模糊层
    [self setEffectView:effectView];
    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        [make size].equalTo(backgroundView);
        [make center].equalTo(backgroundView);
    }];
    
    // 背景手势
    UITapGestureRecognizer *backgroundViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapCall:)];
    [backgroundViewTapGesture setDelegate:self];
    [backgroundView addGestureRecognizer:backgroundViewTapGesture];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setSectionInset:UIEdgeInsetsZero];
    [layout setMinimumLineSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    [layout setHeaderReferenceSize:CGSizeZero];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    [collectionView registerClass:[ZTMenuCell class] forCellWithReuseIdentifier:@"cell"];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView setShowsHorizontalScrollIndicator:NO];
    [collectionView setShowsVerticalScrollIndicator:NO];
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *))
    {
        if ([collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)])
        {
            [collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }
#endif
    [self setCollectionView:collectionView];
    [backgroundView addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        [[make leading] trailing].equalTo(backgroundView);
        [make bottom].equalTo([backgroundView mas_top]);
        [make height].mas_equalTo([self contentHeight]);
    }];
    
    return;
}

#pragma mark - 数据相关
- (void)setData:(NSArray *)data
{
    if ([self isAddToView])
    {
        [self showData:data];
    }
    else
    {
        [self setTempData:data];
    }
    
    return;
}

- (void)showData:(NSArray *)data
{
    NSString *title = nil;
    NSUInteger count = [[self data] count];
    int i = 0;
    
    if ([data count] == 0)
    {
        if (count > 0)
        {
            i = -1;
        }
        else
        {
            i = 1;
        }
        
        UIViewController *VC = [self VC];
        title = [VC title];
        _index = -1;
    }
    else
    {
        title = [data objectAtIndex:0];
        _index = 0;
    }
    
    [[self titleLabel] setText:title];
    _data = data;
    
    if (i == 1)
    {
        return;
    }
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    kZTWeakSelf(weakSelf);
    [[self collectionView] performBatchUpdates:^{
        if (i == -1)
        {
            [[weakSelf collectionView] deleteSections:indexSet];
        }
        else
        {
            [[weakSelf collectionView] reloadSections:indexSet];
        }
    } completion:^(BOOL finished) {
    }];
    
    return;
}

#pragma mark - 重写方法
- (void)setTitleFont:(UIFont *)titleFont
{
    if ((titleFont == nil) || (![titleFont isKindOfClass:[UIFont class]]))
    {
        titleFont = kZTDefaultTitleFont;
    }
    
    _titleFont = titleFont;
    [[self titleLabel] setFont:titleFont];
    
    return;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    if ((titleColor == nil) || (![titleColor isKindOfClass:[UIColor class]]))
    {
        titleColor = kZTDefaultTitleColor;
    }
    
    _titleColor = titleColor;
    [[self titleLabel] setTextColor:titleColor];
    
    return;
}

- (void)setLayoutGuideBottom:(int)layoutGuideBottom
{
    if (layoutGuideBottom == [self layoutGuideBottom])
    {
        return;
    }
    
    if (layoutGuideBottom < kZTLayoutGuideBottomMin || layoutGuideBottom > kZTLayoutGuideBottomMax)
    {
        _layoutGuideBottom = 0;
    }
    else
    {
        _layoutGuideBottom = layoutGuideBottom;
    }
    
    if ([self isAddToView])
    {
        UIViewController *VC = [self VC];
        UIView *view = [VC view];
        
        MASViewAttribute *bottom = [VC mas_bottomLayoutGuideBottom];
        CGFloat offset = 0;
        if ([self layoutGuideBottom] > 0)
        {
            offset = [self layoutGuideBottom];
        }
        else
        {
            if ([self isShowBar])
            {
                bottom = [VC mas_bottomLayoutGuideTop];
            }
        }
        
        [[self backgroundView] mas_remakeConstraints:^(MASConstraintMaker *make) {
            [[make trailing] leading].equalTo(view);
            [make top].equalTo([VC mas_topLayoutGuideBottom]);
            [make bottom].equalTo(bottom).offset(-offset);
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [[[self VC] view] layoutIfNeeded];
        }];
    }
    
    return;
}

- (void)setContentHeight:(int)contentHeight
{
    if (contentHeight == [self contentHeight])
    {
        return;
    }
    
    if (contentHeight < kZTContentHeightMin)
    {
        contentHeight = kZTContentHeightMin;
    }
    else if (contentHeight > kZTContentHeightMax)
    {
        contentHeight = kZTContentHeightMax;
    }
    
    _contentHeight = contentHeight;
    
    if ([self isAddToView])
    {
        [[self collectionView] mas_updateConstraints:^(MASConstraintMaker *make) {
            [make height].mas_equalTo(contentHeight);
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [[[self VC] view] layoutIfNeeded];
        }];
    }
    
    return;
}

- (void)setCellHeight:(int)cellHeight
{
    if (cellHeight == [self cellHeight])
    {
        return;
    }
    
    if (cellHeight < kZTCellHeightMin)
    {
        cellHeight = kZTCellHeightMin;
    }
    else if (cellHeight > kZTCellHeightMax)
    {
        cellHeight = kZTCellHeightMax;
    }
    
    _cellHeight = cellHeight;
    
    if ([self isAddToView])
    {
        [[self collectionView] reloadData];
    }
    
    return;
}

- (void)setMenuWidth:(int)menuWidth
{
    if (menuWidth == [self menuWidth])
    {
        return;
    }
    
    if (menuWidth < kZTMenuWidthMin)
    {
        menuWidth = kZTMenuWidthMin;
    }
    else if (menuWidth > kZTMenuWidthMax)
    {
        menuWidth = kZTMenuWidthMax;
    }
    
    _menuWidth = menuWidth;
    
    if ([self isAddToView])
    {
        [self updateMenuWidth];
    }
    
    return;
}

- (void)setEffectStyle:(UIBlurEffectStyle)effectStyle
{
    switch (effectStyle)
    {
        case UIBlurEffectStyleExtraLight:
        case UIBlurEffectStyleLight:
        case UIBlurEffectStyleDark:
#ifdef __IPHONE_10_0
        case UIBlurEffectStyleRegular:
        case UIBlurEffectStyleProminent:
#endif
            _effectStyle = effectStyle;
            break;
            
        default:
            _effectStyle = UIBlurEffectStyleLight;
            break;
    }
    
    return;
}

- (void)setEffectAlpha:(CGFloat)effectAlpha
{
    if (effectAlpha == [self effectAlpha])
    {
        return;
    }
    
    if (effectAlpha < kZTEffectAlphaMin)
    {
        effectAlpha = kZTEffectAlphaMin;
    }
    else if (effectAlpha > kZTEffectAlphaMax)
    {
        effectAlpha = kZTEffectAlphaMax;
    }
    
    _effectAlpha = effectAlpha;
    [[self effectView] setAlpha:effectAlpha];
    
    return;
}

#pragma mark - 点击事件
- (void)backgroundViewTapCall:(UITapGestureRecognizer *)tapGesture
{
    if([self isTapBackgroundHidden])
    {
        [self hiddenNavigationMenu];
    }
    
    return;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch view] == [self effectView])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - 外部方法
- (void)addBlock:(ZTNavigationMenuBlock)block
{
    [self setBlock:[block copy]];
    
    return;
}

- (BOOL)updateImage:(NSString *)imageName andSize:(CGSize)size
{
    BOOL flag = NO;
    UIImage *image = [UIImage imageNamed:imageName];
    if (image == nil)
    {
        image = [UIImage imageNamed:@"ZTNavigationMenu_arrow"];
        size = CGSizeMake(14, 14);
    }
    else
    {
        if (size.width == 0 || size.height == 0)
        {
            size = CGSizeMake(14, 14);
        }
        else
        {
            if (size.width > 44)
            {
                size.width = 44;
            }
            
            if (size.height > 44)
            {
                size.height = 44;
            }
        }
        
        flag = YES;
    }
    
    [[self imageView] setImage:image];
    [[self imageView] mas_updateConstraints:^(MASConstraintMaker *make) {
        [make size].mas_equalTo(size);
    }];
    [self layoutIfNeeded];
    
    return flag;
}

- (BOOL)updateIndex:(int)index
{
    if (index < 0)
    {
        return NO;
    }
    
    BOOL flag = NO;
    if ([self isAddToView])
    {
        NSArray *data = [self data];
        if ((index < [data count]) && (index != [self index]))
        {
            NSString *text = [data objectAtIndex:index];
            [[self titleLabel] setText:text];
            
            ZTMenuCell *lastCell = (ZTMenuCell *)[[self collectionView] cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self index] inSection:0]];
            [lastCell resetButton];
            
            ZTMenuCell *currentCell = (ZTMenuCell *)[[self collectionView] cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            [currentCell selecteButton];
            
            _index = index;
            flag = YES;
        }
    }
    else
    {
        [self setTempIndex:index];
        flag = YES;
    }
    
    return flag;
}

- (void)invalidate
{
    [self ex_removeFromSuperview];
    [[self backgroundView] removeFromSuperview];
    UIViewController *VC = [self VC];
    [[VC navigationItem] setTitleView:nil];
    [self setBlock:nil];
    [self setVC:nil];
    [self setBackgroundView:nil];
    [self setTitleLabel:nil];
    [self setImageView:nil];
    
    return;
}

#pragma mark - 显示 && 隐藏相关
- (void)hiddenNavigationMenu
{
    if ([self isSelected] == NO)
    {
        return;
    }
    
    [self hiddenNavigationMenuWithBlock:nil];
    
    return;
}

- (void)hiddenNavigationMenuWithBlock:(ZTNavigationMenuBlock)block
{
    [self setSelected:NO];
    UIView *backgroundView = [self backgroundView];
    
    [[self collectionView] mas_remakeConstraints:^(MASConstraintMaker *make) {
        [[make leading] trailing].equalTo(backgroundView);
        [make bottom].equalTo([backgroundView mas_top]);
        [make height].mas_equalTo([self contentHeight]);
    }];
    
    [UIView animateWithDuration:0.5f animations:^{
        [[self imageView] setTransform:CGAffineTransformMakeRotation(-M_PI * 2)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [[self effectView] setEffect:nil];
        [[[self VC] view] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [backgroundView setHidden:YES];
        [[[self VC] view] sendSubviewToBack:backgroundView];
        
        if (block)
        {
            block([self data], [self index]);
        }
    }];
    
    return;
}

- (void)tapCall
{
    if ([self isSelected] == NO)
    {
        [self setSelected:YES];
        UIView *backgroundView = [self backgroundView];
        [backgroundView setHidden:NO];
        [[[self VC] view] bringSubviewToFront:backgroundView];
        
        [UIView animateWithDuration:0.5f animations:^{
            if ([self isRotate])
            {
                [[self imageView] setTransform:CGAffineTransformMakeRotation(M_PI)];
            }
            
            switch ([self style])
            {
                case ZTBackgroundStyleTranslucent:
                    [backgroundView setBackgroundColor:kZTRGBA(0, 0, 0, 0.5f)];
                    break;
                    
                case ZTBackgroundStyleEffect:
                {
                    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:[self effectStyle]];
                    [[self effectView] setEffect:effect];
                }
                    break;
                    
                default:
                    break;
            }
            
            [[self collectionView] mas_remakeConstraints:^(MASConstraintMaker *make) {
                [[make leading] trailing].equalTo(backgroundView);
                [make top].equalTo([backgroundView mas_top]);
                [make height].mas_equalTo([self contentHeight]);
            }];
            
            [[[self VC] view] layoutIfNeeded];
        }];
    }
    else
    {
        [self hiddenNavigationMenu];
    }
    
    return;
}

#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kZTScreenWidth, [self cellHeight]);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self data] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger currentIndex = [indexPath item];
    ZTMenuCell *cell = (ZTMenuCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setText:[[self data] objectAtIndex:currentIndex]];
    
    if ([self index] == currentIndex)
    {
        [cell selecteButton];
    }
    else
    {
        [cell resetButton];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [self index];
    int currentIndex = (int)[indexPath item];
    if (index == currentIndex)
    {
        [self hiddenNavigationMenu];
        
        return;
    }
    
    NSString *title = [[self data] objectAtIndex:[indexPath item]];
    [[self titleLabel] setText:title];
    
    ZTMenuCell *currentCell = (ZTMenuCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [currentCell selecteButton];
    
    ZTMenuCell *lastCell = (ZTMenuCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self index] inSection:0]];
    [lastCell resetButton];
    
    _index = currentIndex;
    [self hiddenNavigationMenuWithBlock:[self block]];
    
    return;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return NO;
}

@end
