//
//  ZTMenuCell.m
//  ZTNavigationMenuDemo
//
//  Created by Cer on 2018/9/27.
//  Copyright © 2018年 Cer. All rights reserved.
//

#import "ZTMenuCell.h"
#import "ZTPrefixHeader.pch"

@interface ZTMenuCell ()

@property(nonatomic, strong) UIButton *button;

@end

@implementation ZTMenuCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self createView];
    }
    
    return self;
}

//- (void)dealloc
//{
//    NSLog(@"cell 销毁");
//
//    return;
//}

- (void)createView
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setUserInteractionEnabled:NO];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:16]];
    [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x6DA67E) forState:UIControlStateSelected];
    [button setTitleColor:UIColorFromRGB(0x6DA67E) forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[self contentView] addSubview:button];
    [self setButton:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        [make size].equalTo(self);
        [make top].equalTo(self);
        [make bottom].equalTo(self).offset(-1);
    }];
    
    UIView *line = [[UIView alloc] init];
    [line setBackgroundColor:UIColorFromRGB(0xF2F2F2)];
    [[self contentView] addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        [make height].mas_equalTo(1);
        [[make leading] trailing].equalTo(self);
        [make bottom].equalTo(self);
    }];
    
    return;
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    [[self button] setTitle:text forState:UIControlStateNormal];
    
    return;
}

- (void)selecteButton
{
    [[self button] setSelected:YES];
    
    return;
}

- (void)resetButton
{
    [[self button] setSelected:NO];
    
    return;
}

@end
