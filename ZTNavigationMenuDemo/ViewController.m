//
//  ViewController.m
//  ZTNavigationMenuDemo
//
//  Created by Cer on 2018/10/8.
//  Copyright © 2018年 Cer. All rights reserved.
//

#import "ViewController.h"
#import "RootViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"首页"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"push" style:UIBarButtonItemStylePlain target:self action:@selector(push)];
    [[self navigationItem] setRightBarButtonItem:item animated:NO];
    
    return;
}

- (void)push
{
    RootViewController *VC = [[RootViewController alloc] init];
    [[self navigationController] pushViewController:VC animated:YES];
    
    return;
}

@end
