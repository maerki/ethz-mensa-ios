//
//  ETHMensaMenuView.h
//  Campus
//
//  Created by Nicolas Märki on 09.11.13.
//  Copyright (c) 2013 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETHMensaContentViewController;

@interface ETHMensaMenuCell : UICollectionViewCell

@property (nonatomic, strong) NSDictionary *menu;
@property (nonatomic, strong) NSDictionary *mensa;

+ (UIFont *)titleFont;
+ (UIFont *)contentFont;

+ (CGSize)sizeWithItem:(NSDictionary *)menu parentSize:(CGSize)size;

@property (nonatomic, weak) ETHMensaContentViewController *delegate;

@end
