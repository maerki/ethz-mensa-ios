//
//  ETHMensaWeekMenuCell.m
//  Mensa
//
//  Created by Nicolas Märki on 17.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaWeekMenuCell.h"

#import "ETHMensaMenuCell.h"

@interface ETHMensaWeekMenuCell ()


@end

@implementation ETHMensaWeekMenuCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.titleLabel = [UILabel new];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [ETHMensaMenuCell titleFont];
        [self.titleLabel addShadow];
        [self addSubview:self.titleLabel];

        self.descriptionLabel = [UILabel new];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.font = [ETHMensaMenuCell contentFont];
        [self.descriptionLabel addShadow];
        [self addSubview:self.descriptionLabel];
    }
    return self;
}

- (void)setMenu:(NSDictionary *)menu
{

    _menu = menu;

    self.titleLabel.text = menu[@"name"];
    self.descriptionLabel.text = menu[@"menu"];
}

- (void)setPast:(BOOL)past {
    _past = past;
    if(past) {
        self.titleLabel.alpha = 0.5;
        self.descriptionLabel.alpha = 0.5;
    }
    else {
        self.titleLabel.alpha = 1;
        self.descriptionLabel.alpha = 1;
    }
}

- (void)layoutSubviews
{

    float padding = 15;
    float textPadding = 5;

    float textWidth = self.bounds.size.width - 2 * padding;

    float titleHeight = [self.titleLabel.text
                            boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@
                                      {
                                          NSFontAttributeName: self.titleLabel.font
                                      }
                                         context:nil].size.height;
    self.titleLabel.frame = CGRectMake(padding, 5, textWidth, titleHeight);

    float descriptionHeight = [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin |
                                                                               NSStringDrawingUsesFontLeading
                                                                    attributes:@
                                                                    {
                                                                        NSFontAttributeName: self.descriptionLabel.font
                                                                    }
                                                                       context:nil].size.height;
    self.descriptionLabel.frame =
        CGRectMake(padding, CGRectGetMaxY(self.titleLabel.frame) + textPadding, textWidth, descriptionHeight + 3.0);
}

+ (CGSize)sizeWithItem:(NSDictionary *)menu parentSize:(CGSize)size
{
    float padding = 15;
    float textPadding = 5;
    
    float width = size.width / (floorf(size.width/320.0f));


    float textWidth = width - 2 * padding;
    float titleHeight =
        [menu[@"name"] boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:@
                                 {
                                     NSFontAttributeName: [ETHMensaMenuCell titleFont]
                                 }
                                    context:nil].size.height;
    float descriptionHeight =
        [menu[@"menu"] boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                 attributes:@
                                 {
                                     NSFontAttributeName: [ETHMensaMenuCell contentFont]
                                 }
                                    context:nil].size.height;

    float h = titleHeight + descriptionHeight + padding + textPadding + 5;

    return CGSizeMake(width, h);
}

@end
