//
//  ETHMensaHeaderView.m
//  Mensa
//
//  Created by Nicolas Märki on 17.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaSectionHeaderView.h"

@implementation ETHMensaSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.titleLabel addShadow];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    self.titleLabel.frame = CGRectMake(15, 5, self.frame.size.width - 30, self.frame.size.height - 5);
}

@end
