//
//  ZTNavigationMenu.h
//  ZTNavigationMenuDemo
//
//  Created by Cer on 2018/9/27.
//  Copyright © 2018年 Cer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZTNavigationMenuBlock)(NSArray<NSString *> *data, int index);

@interface ZTNavigationMenu : UIControl

@property(nonatomic, strong) NSArray<NSString *> *data;
@property(nonatomic, assign, readonly) int index;
@property(nonatomic, assign) int menuWidth;
@property(nonatomic, assign) int cellHeight;
@property(nonatomic, assign) int contentHeight;
@property(nonatomic, assign) int layoutGuideBottom;
@property(nonatomic, assign) UIBlurEffectStyle effectStyle;
@property(nonatomic, assign) CGFloat effectAlpha;
@property(nonatomic, assign, getter=isShowBackgroundView) BOOL showBackgroundView;
@property(nonatomic, assign, getter=isShowEffectView) BOOL showEffectView;
@property(nonatomic, assign, getter=isTapBackgroundHidden) BOOL tapBackgroundHidden;
@property(nonatomic, assign, getter=isRotate) BOOL rotate;

+ (instancetype)navigationMenu;
+ (instancetype)navigationMenuWithBlock:(ZTNavigationMenuBlock)block;
- (instancetype)initWithBlock:(ZTNavigationMenuBlock)block;

- (void)addBlock:(ZTNavigationMenuBlock)block;
- (void)hiddenNavigationMenu;
- (BOOL)updateImage:(NSString *)imageName andSize:(CGSize)size;
- (BOOL)updateIndex:(int)index;
- (void)invalidate;

@end
