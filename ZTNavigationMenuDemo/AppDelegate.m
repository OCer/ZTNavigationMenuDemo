//
//  AppDelegate.m
//  ZTNavigationMenuDemo
//
//  Created by Cer on 2018/9/27.
//  Copyright © 2018年 Cer. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    
    UIWindow *window = [[UIWindow alloc] init];
    [self setWindow:window];
    [window setFrame:[[UIScreen mainScreen] bounds]];
    [window setBackgroundColor:[UIColor whiteColor]];
    
//    ViewController *rootController = [[ViewController alloc] init];
    RootViewController *rootController = [[RootViewController alloc] init];
    UINavigationController *rootNavigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    [window setRootViewController:rootNavigation];
    [window makeKeyAndVisible];

    return YES;
}

@end
