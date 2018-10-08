//
//  ZTMenuCell.h
//  ZTNavigationMenuDemo
//
//  Created by Cer on 2018/9/27.
//  Copyright © 2018年 Cer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZTMenuCell : UICollectionViewCell

@property(nonatomic, copy) NSString *text;

- (void)selecteButton;
- (void)resetButton; 

@end
