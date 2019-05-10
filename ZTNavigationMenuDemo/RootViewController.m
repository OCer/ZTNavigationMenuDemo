//
//  RootViewController.m
//  ZTNavigationMenuDemo
//
//  Created by Cer on 2018/9/27.
//  Copyright © 2018年 Cer. All rights reserved.
//

#import "RootViewController.h"
#import "ZTNavigationMenu.h"
#import "ViewController.h"
#import "Masonry.h"

@interface RootViewController ()

@property(nonatomic, strong) ZTNavigationMenu *titleView;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createView];
    
    NSArray *data = [[NSArray alloc] initWithObjects:@"Objective-C", @"Swift", @"CPP", @"Java", @"PHP", @"SQL Server", nil];
    ZTNavigationMenuBlock block = ^(NSArray<NSString *> *data, int index) {
        NSLog(@"data = %@", [data objectAtIndex:index]);
    };
    
    // 创建导航栏下拉菜单
    ZTNavigationMenu *titleView = [[ZTNavigationMenu alloc] initWithBlock:block];
    [titleView setData:data];
    [[self navigationItem] setTitleView:titleView];
    [self setTitleView:titleView];
    
    // 取消遮罩显示
//    [titleView setStyle:ZTBackgroundStyleNone];
    
    // 显示模糊视图
//    [titleView setStyle:ZTBackgroundStyleEffect];
    
    // 点击遮罩不隐藏
//    [titleView setTapBackgroundHidden:NO];
    
    // 替换block
//    [titleView addBlock:^(NSArray<NSString *> *data, int index) {
//        NSLog(@"index = %d", index);
//    }];
    
    return;
}

- (void)createView
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"改变" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonCall)];
    [[self navigationItem] setRightBarButtonItem:item animated:NO];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setImage:[UIImage imageNamed:@"mac.jpg"]];
    [imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];    
    [[self view] addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        [make size].mas_equalTo(CGSizeMake(340, 226.6f));
        [make center].equalTo([self view]);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    [titleLabel setTextColor:[UIColor grayColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:@"mac.jpg"];
    [[self view] addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        [make top].equalTo([imageView mas_bottom]);
        [make height].mas_equalTo(30);
        [make centerX].equalTo(imageView);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:16]];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [button setTitle:@"这是个危险按钮" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonCall) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        [make size].mas_equalTo(CGSizeMake(150, 30));
        [make top].equalTo([titleLabel mas_bottom]).offset(50);
        [make centerX].equalTo(imageView);
    }];
    
    return;
}

- (void)buttonCall
{
    NSLog(@"大哥 别点了  小弟知错了");
    
    // 测试切换index
//    [[self titleView] updateIndex:3];
//    NSLog(@"index = %d", [[self titleView] index]);
    
    return;
}

- (void)barButtonCall
{
    // 测试跳转
//    ViewController *VC = [[ViewController alloc] init];
//    [[self titleView] hiddenNavigationMenu];
//    [[self navigationController] pushViewController:VC animated:YES];
    
    // 测试修改箭头图标
//    [[self titleView] setRotate:NO];
//    [[self titleView] updateImage:@"menu" andSize:CGSizeMake(19, 15)];
    
    // 测试修改宽度
//    CGFloat width = arc4random() % 61 + 140;
//    NSLog(@"切换宽度响应 = %.0f", width);
//    [[self titleView] setMenuWidth:width];
    
    // 测试修改cell高度
//    CGFloat height = arc4random() % 71 + 30;
//    NSLog(@"切换高度响应 = %.0f", height);
//    [[self titleView] setCellHeight:height];
    
    // 测试修改内容高度
//    CGFloat height = arc4random() % 251 + 100;
//    NSLog(@"切换高度响应 = %.0f", height);
//    [[self titleView] setContentHeight:height];
    
    // 测试模糊类型
//    [[self titleView] setStyle:ZTBackgroundStyleEffect];
//    [[self titleView] setEffectStyle:UIBlurEffectStyleRegular];
    
    // 测试修改底部高度
//    [[self titleView] setLayoutGuideBottom:100];
    
    // 测试修改标题文本样式
//    [[self titleView] setTitleColor:[UIColor colorWithRed:0.86 green:0.23 blue:0.91 alpha:0.8]];
//    [[self titleView] setTitleFont:[UIFont systemFontOfSize:16]];

    return;
}

//- (void)dealloc
//{
//    NSLog(@"控制器 销毁");
//
//    return;
//}

@end
