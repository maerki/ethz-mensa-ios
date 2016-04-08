//
//  ETHMensaHeaderView.h
//  Mensa
//
//  Created by Nicolas Märki on 11.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETHMensaHeaderView : UIView

@property (nonatomic, strong) NSArray *mensen;

@property (nonatomic) float position;

@property (nonatomic) NSUInteger mainTypeIndex, secondaryTypeIndex;

@end
