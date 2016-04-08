//
//  ETHMensaMenuView.m
//  Campus
//
//  Created by Nicolas Märki on 09.11.13.
//  Copyright (c) 2013 Nicolas Märki. All rights reserved.
//

#import "ETHMensaMenuCell.h"

#import "UIKit+AFNetworking.h"

#import "ETHMensaContentViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface ETHMensaMenuCell ()

@property (nonatomic, strong) UILabel *titleLabel, *descriptionLabel, *priceLabel, *likeCountLabel;

@property (nonatomic, strong) UIView *topLine;

@property (nonatomic, strong) UIButton *shareImageButton, *likeButton;

@property (nonatomic, strong) UIScrollView *imageContainer;
@property (nonatomic, strong) NSMutableArray *imageViews;

@property (nonatomic, strong) UIActivityIndicatorView *imageAiv;

@end

@implementation ETHMensaMenuCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {

        //        self.backgroundColor = [UIColor whiteColor];
        //
        //        self.layer.shadowOffset = CGSizeMake(0, 0.5f);
        //        self.layer.shadowRadius = 1.0f;
        //        self.layer.shadowOpacity = 0.3f;

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

        self.priceLabel = [UILabel new];
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceLabel.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] fontWithSize:13];
        self.priceLabel.numberOfLines = 0;
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self.priceLabel addShadow];
        [self addSubview:self.priceLabel];

        self.likeCountLabel = [UILabel new];
        self.likeCountLabel.textColor = [UIColor whiteColor];
        self.likeCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        self.likeCountLabel.numberOfLines = 0;
        self.likeCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.likeCountLabel addShadow];
        [self addSubview:self.likeCountLabel];

        self.topLine = [UIView new];
        self.topLine.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2];
        [self addSubview:self.topLine];

        self.imageContainer = [UIScrollView new];
        self.imageContainer.scrollsToTop = NO;
        self.imageContainer.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.imageContainer];

        self.shareImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self addSubview:self.shareImageButton];
        //        self.shareImageButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        [self.shareImageButton addTarget:self
                                  action:@selector(shareImage:)
                        forControlEvents:UIControlEventTouchUpInside];
        //        self.shareImageButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.03];
        self.shareImageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        self.shareImageButton.tintColor = [UIColor colorWithWhite:1 alpha:1];
        //        self.shareImageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.shareImageButton.alpha = 0.5;
        self.shareImageButton.layer.cornerRadius = 4.0f;
        self.shareImageButton.layer.borderWidth = 0.5;
        self.shareImageButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;

        self.likeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self addSubview:self.likeButton];
        self.likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        [self.likeButton addTarget:self action:@selector(likeMenu:) forControlEvents:UIControlEventTouchUpInside];
        //        self.likeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.03];
        self.likeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        self.likeButton.tintColor = [UIColor colorWithWhite:1 alpha:1];

        [self.likeButton addShadow];

        self.imageViews = [NSMutableArray array];

        self.imageAiv =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.imageContainer addSubview:self.imageAiv];
    }
    return self;
}

+ (UIFont *)titleFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}
+ (UIFont *)contentFont
{
    return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)setMenu:(NSDictionary *)menu
{

    _menu = menu;

    self.titleLabel.text = menu[@"name"];
    self.descriptionLabel.text = menu[@"menu"];

    NSString *priceString =
        [NSString stringWithFormat:@"%.2f\n%.2f\n%.2f", [menu[@"preis_stud"] floatValue],
                                   [menu[@"preis_angest"] floatValue], [menu[@"preis_extern"] floatValue]];
    self.priceLabel.text = priceString;

    //    [self.shareImageButton setImage:[UIImage imageNamed:@"icnCamera"] forState:UIControlStateNormal];

    [self.shareImageButton setTitle:NSLocalizedString(@"Add Image", @"Mensa, Share Button Title")
                           forState:UIControlStateNormal];

    if([menu[@"userLiked"] boolValue])
    {
        [self.likeButton setImage:[UIImage imageNamed:@"icnStarSelected"] forState:UIControlStateNormal];
    }
    else
    {
        [self.likeButton setImage:[UIImage imageNamed:@"icnStar"] forState:UIControlStateNormal];
    }

    self.likeCountLabel.text = [menu[@"likes"] description];

    [self updateImages];
}

- (void)layoutSubviews
{

    float padding = 16;
    float textPadding = 5;

    float paddingTop = 5.0f;
    float paddingBottom = 20.0f;

    self.topLine.frame = CGRectMake(60.0, paddingTop, 0.5, self.frame.size.height - paddingTop - paddingBottom);

    float textWidth = self.bounds.size.width - self.topLine.frame.origin.x - 2 * padding;

    float titleHeight = [self.titleLabel.text
                            boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@
                                      {
                                          NSFontAttributeName: self.titleLabel.font
                                      }
                                         context:nil].size.height;
    self.titleLabel.frame =
        CGRectMake(self.topLine.frame.origin.x + padding, CGRectGetMinY(self.topLine.frame), textWidth, titleHeight);

    float descriptionHeight = [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin |
                                                                               NSStringDrawingUsesFontLeading
                                                                    attributes:@
                                                                    {
                                                                        NSFontAttributeName: self.descriptionLabel.font
                                                                    }
                                                                       context:nil].size.height;
    self.descriptionLabel.frame =
        CGRectMake(self.topLine.frame.origin.x + padding, CGRectGetMaxY(self.titleLabel.frame) + textPadding, textWidth,
                   descriptionHeight+3);

    self.priceLabel.frame = CGRectMake(0, 62.0 + paddingTop, self.topLine.frame.origin.x - padding, 60.0);

    const float buttonHeight = 30;

    self.imageContainer.frame =
        CGRectMake(self.topLine.frame.origin.x + 1, CGRectGetMaxY(self.descriptionLabel.frame) + padding,
                   self.frame.size.width - self.topLine.frame.origin.x - 1, 60);

    self.imageAiv.frame =
        CGRectMake(self.imageContainer.contentSize.width + 10.0f,
                   self.imageContainer.frame.size.height / 2.0f - self.imageAiv.frame.size.height / 2.0f,
                   self.imageAiv.frame.size.width, self.imageAiv.frame.size.height);

    self.shareImageButton.frame = CGRectMake(self.topLine.frame.origin.x + padding,
                                             self.frame.size.height - buttonHeight - paddingBottom, 100, buttonHeight);
    ;

    self.likeButton.frame = CGRectMake(0, -5 + paddingTop, self.topLine.frame.origin.x, 40);
    self.likeCountLabel.frame = CGRectMake(0, 28 + paddingTop, self.topLine.frame.origin.x, 20);
}

+ (CGSize)sizeWithItem:(NSDictionary *)menu parentSize:(CGSize)size
{
    float imageSize = 60;
    float padding = 16;
    float textPadding = 5;

    float width = size.width / (floorf(size.width / 320.0f));

    float textWidth = width - imageSize - 2 * padding;
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

    float imageHeight = 100;
    if([menu[@"images"] count] == 0)
    {
        imageHeight = 20;
    }

    float h = titleHeight + descriptionHeight + padding + textPadding + imageHeight + 5.0f;

    h = MAX(h, 113.0f) + 25;

    return CGSizeMake(width, h);
}

- (void)updateImages
{

    NSDictionary *menu = _menu;

    while(self.imageViews.count > 0)
    {
        [self.imageViews[0] removeFromSuperview];
        [self.imageViews removeObjectAtIndex:0];
    }

    float p = 15.0f;

    BOOL loading = NO;

    for(int i = 0; i < [menu[@"images"] count]; i++)
    {

        //        UIView *imgShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        //        imgShadow.layer.shadowOffset = CGSizeMake(0, 0);
        //        imgShadow.layer.shadowOpacity = 0.3;
        //        imgShadow.layer.shadowRadius = 0.5f;
        //        imgShadow.backgroundColor = [UIColor whiteColor];
        //        imgShadow.layer.shouldRasterize = YES;

        __block NSMutableDictionary *imgObject = menu[@"images"][i];

        UIImageView *imgv = [[UIImageView alloc] init];
        imgv.clipsToBounds = YES;

        imgv.layer.borderColor = [UIColor whiteColor].CGColor;
        imgv.layer.borderWidth = 1.0f;

        if([imgObject[@"loading"] boolValue])
        {
            imgv.image = nil;
            loading = YES;
        }
        else if(!imgObject[@"thumb"])
        {
            int imgId = [imgObject[@"id"] intValue];
            imgObject[@"loading"] = @YES;
            loading = YES;

            NSString *thumbUrl =
                [NSString stringWithFormat:@"BACKEND_API_PATH", imgId];

            [ETHBackend loadImage:thumbUrl
                         complete:^(UIImage *image, NSError *error)
                                  {
                             imgObject[@"loading"] = @NO;
                             imgObject[@"thumb"] = image;

                             [self updateImages];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"ETHMensaDidUpdateMenus"
                                                                                 object:self.mensa];
                         }];
        }
        else
        {
            [imgv setImage:imgObject[@"thumb"]];
        }

        float w = imgv.image.size.width / (imgv.image.size.height + 1.0) * 60.0;
        imgv.frame = CGRectMake(p, 0, w, 60);

        //        imgv.layer.zPosition = -i;
        //        imgv.transform = CGAffineTransformTranslate(
        //            CGAffineTransformMakeScale(1.0 - 0.05 * (float)i, 1.0 - 0.1 * (float)i), 25.0 * (float)i, 0);
        //        imgv.alpha = 1.0f - (float)i * 0.1;
        p += w + 10;
        [self.imageContainer addSubview:imgv];
        [self.imageViews addObject:imgv];

        UITapGestureRecognizer *gr = [UITapGestureRecognizer new];
        [gr addTarget:self action:@selector(tapImage:)];
        [imgv addGestureRecognizer:gr];
        imgv.tag = i;
        imgv.userInteractionEnabled = YES;
    }

    self.imageContainer.contentSize = CGSizeMake(p, 60);

    if(loading)
    {
        [self.imageAiv startAnimating];
    }
    else
    {
        [self.imageAiv stopAnimating];
    }

    [self setNeedsLayout];
}

- (void)shareImage:(id)sender
{

    [self.delegate shareImage:(NSMutableDictionary *)self.menu];
}

- (void)likeMenu:(id)sender
{
    [self.delegate likeMenu:(NSMutableDictionary *)self.menu];
}

- (void)tapImage:(UITapGestureRecognizer *)sender
{
    [self.delegate openImage:(NSMutableDictionary *)self.menu index:sender.view.tag];
}

@end
