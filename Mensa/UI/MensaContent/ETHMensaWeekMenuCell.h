//
//  ETHMensaWeekMenuCell.h
//  Mensa
//
//  Created by Nicolas Märki on 17.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETHMensaWeekMenuCell : UICollectionViewCell

@property (nonatomic, strong) NSDictionary *menu;

@property (nonatomic) BOOL past;

@property (nonatomic, strong) UILabel *titleLabel, *descriptionLabel;


+ (CGSize)sizeWithItem:(NSDictionary *)menu parentSize:(CGSize)size;

@end
