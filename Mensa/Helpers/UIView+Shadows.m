//
//  UIView+Shadows.m
//  Mensa
//
//  Created by Nicolas Märki on 16.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "UIView+Shadows.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (Shadows)

- (void)addShadow
{

    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = 2.0f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.3f;
    self.layer.shadowRadius = 0.5;
    self.layer.shadowOffset = CGSizeMake(0, 0.5);
}

- (void)removeShadow
{

    self.layer.shadowColor = [UIColor clearColor].CGColor;
    self.layer.shadowOpacity = 0.0f;
    self.layer.shadowRadius = 0.0;
    self.layer.shadowOffset = CGSizeMake(0, 0);
}

@end
