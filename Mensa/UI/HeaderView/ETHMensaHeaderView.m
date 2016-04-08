//
//  ETHMensaHeaderView.m
//  Mensa
//
//  Created by Nicolas Märki on 11.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaHeaderView.h"

#import "UIKit+AFNetworking.h"

@import QuartzCore;

@interface ETHMensaHeaderView ()

@property (nonatomic, strong) UIView *bottomLine, *contentView;
@property (nonatomic, strong) NSMutableArray *titleLabels, *headerImages;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIView *mainButtonsView, *secondaryButtonsView;
@property (nonatomic, strong) UIView *line1, *line2, *line3, *secondaryLine1, *secondaryLine2;

@property (nonatomic, strong) UIButton *button1, *button2, *button3, *button4, *secondaryButton1, *secondaryButton2;

@property (nonatomic, strong) UIView *mainSelection, *secondarySelection;

@end

@implementation ETHMensaHeaderView

const CGFloat lineAlpha = 0.2f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {

        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.contentView];

        self.bottomLine = [UIView new];
        self.bottomLine.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
        [self.contentView addSubview:self.bottomLine];

        self.pageControl = [UIPageControl new];
        [self.contentView addSubview:self.pageControl];

        self.mainButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20.0f)];
        [self.contentView addSubview:self.mainButtonsView];
        self.secondaryButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20.0f)];
        [self.contentView addSubview:self.secondaryButtonsView];

        self.mainSelection = [UIView new];
        self.mainSelection.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
        [self.mainButtonsView addSubview:self.mainSelection];

        self.secondarySelection = [UIView new];
        self.secondarySelection.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
        [self.secondaryButtonsView addSubview:self.secondarySelection];

        [self addSomeButtons];
        [self addSomeLines];

        self.mainTypeIndex = self.secondaryTypeIndex = 1;

        UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
        imgv.frame = CGRectMake(self.frame.size.width / 2.0f - imgv.frame.size.width / 8.0f, -15,
                                imgv.frame.size.width / 4.0f, imgv.frame.size.height / 4.0f);
        imgv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imgv.alpha = 0;
        [self.contentView addSubview:imgv];

        CAShapeLayer *ring = [[CAShapeLayer alloc] init];
        [self.contentView.layer addSublayer:ring];
        ring.strokeColor = [UIColor whiteColor].CGColor;
        ring.fillColor = [UIColor clearColor].CGColor;
        const float radius = 25.0f;
        ring.frame = CGRectMake(0, -30, self.frame.size.width, 50);
        ring.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.frame.size.width / 2.0 - radius, radius,
                                                                      2.0f * radius, 2.0f * radius)].CGPath;
        ring.opacity = 0;
        ring.strokeStart = -M_PI;

        UIView *loadingBar = [UIView new];
        loadingBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        loadingBar.frame = CGRectMake(0, self.frame.size.height, 0, 3);
        loadingBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.contentView addSubview:loadingBar];

        UILabel *load = [[UILabel alloc] initWithFrame:CGRectMake(100, -10, 300, 80)];
        load.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
        load.text = @"REL    AD";
        load.textColor = [UIColor whiteColor];
        load.alpha = 0;
        load.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:load];

        __block BOOL loadingTriggered = NO;

        const float triggerOffset = 50.0f;

        [[NSNotificationCenter defaultCenter]
            addObserverForName:@"pullDown"
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note)
                               {
                        float offset = MAX(0, -[note.userInfo[@"offset"] floatValue]);
                        self.contentView.transform = CGAffineTransformMakeTranslation(0, offset);

                        load.frame = CGRectMake(00, 10 - offset, self.frame.size.width, 80);
                        load.alpha = 0.1f * MIN(1.0, (offset / triggerOffset) * 2.0f - 1.0f);

                        const float xoffset = -10;

                        ring.frame =
                            CGRectMake(-xoffset, -50 - MAX(0, offset - triggerOffset), self.frame.size.width, 50);

                        imgv.frame = CGRectMake(self.frame.size.width / 2.0f - imgv.image.size.width / 8.0f - xoffset,
                                                -15 - MAX(0, offset - triggerOffset), imgv.image.size.width / 4.0f,
                                                imgv.image.size.height / 4.0f);
                        ring.path =
                            [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.frame.size.width / 2.0 - radius,
                                                                              radius, 2.0f * radius, 2.0f * radius)]
                                .CGPath;
                        ring.strokeEnd = offset / triggerOffset;
                        ring.opacity = offset / triggerOffset;

                        if(!loadingTriggered)
                        {
                            imgv.alpha = offset / (4.0f * triggerOffset);
                        }
                        else
                        {
                            imgv.alpha = offset / triggerOffset;
                        }
                        [ring removeAllAnimations];

                        if(offset >= triggerOffset && !loadingTriggered)
                        {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ETHMensaLoadMenus" object:nil];
                            imgv.alpha = 1.0;
                            loadingTriggered = YES;
                        }
                        if(offset <= 0)
                        {
                            loadingTriggered = NO;
                        }
                    }];

        [[NSNotificationCenter defaultCenter]
            addObserverForName:@"ETHMensaDidUpdateMenus"
                        object:nil
                         queue:[NSOperationQueue currentQueue]
                    usingBlock:^(NSNotification *note)
                               {

                        float total = self.mensen.count * 2 + 1;
                        float finished = self.mensen.count * 2 + 1;

                        for(NSDictionary *mensa in self.mensen)
                        {
                            if([mensa[@"loadingDay"] boolValue])
                            {
                                finished--;
                            }
                            if([mensa[@"loadingWeek"] boolValue])
                            {
                                finished--;
                            }
                        }

                        if(total > 0)
                        {
                            if(total == finished)
                            {
                                [UIView animateWithDuration:0.2
                                    delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut |
                                            UIViewAnimationOptionBeginFromCurrentState
                                    animations:^
                                               {
                                        loadingBar.frame =
                                            CGRectMake(0, self.frame.size.height, self.frame.size.width, 3);
                                    }
                                    completion:^(BOOL finished)
                                               {

                                        [UIView animateWithDuration:0.4
                                            delay:0
                                            options:UIViewAnimationOptionBeginFromCurrentState
                                            animations:^
                                                       {
                                                loadingBar.frame =
                                                    CGRectMake(0, self.frame.size.height, self.frame.size.width, 0);
                                                loadingBar.alpha = 0;
                                            }
                                            completion:^(BOOL finished)
                                                       {

                                                loadingBar.frame = CGRectMake(0, self.frame.size.height, 0, 3);
                                            }];
                                    }];
                            }
                            else
                            {
                                loadingBar.alpha = 1;
                                [UIView animateWithDuration:0.2
                                                      delay:0
                                                    options:UIViewAnimationOptionCurveEaseInOut |
                                                            UIViewAnimationOptionBeginFromCurrentState
                                                 animations:^
                                                            {

                                                     loadingBar.frame =
                                                         CGRectMake(0, self.frame.size.height,
                                                                    self.frame.size.width * finished / total, 3);
                                                 }
                                                 completion:nil];
                            }
                        }
                    }];
    }
    return self;
}

/**
 *  Ugly code to add buttons
 *  Not worth a nicer system I think
 */
- (void)addSomeButtons
{

    self.button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button1.tintColor = [UIColor whiteColor];
    [self.button1 setTitle:NSLocalizedString(@"Lunch", @"Tab Title") forState:UIControlStateNormal];
    [self.button1 addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventTouchDown];
    self.button1.tag = 1;
    [self.mainButtonsView addSubview:self.button1];

    self.button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button2.tintColor = [UIColor whiteColor];
    [self.button2 setTitle:NSLocalizedString(@"Dinner", @"Tab Title") forState:UIControlStateNormal];
    [self.button2 addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventTouchDown];
    self.button2.tag = 2;
    [self.mainButtonsView addSubview:self.button2];

    self.button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button3.tintColor = [UIColor whiteColor];
    [self.button3 setTitle:NSLocalizedString(@"Week", @"Tab Title") forState:UIControlStateNormal];
    [self.button3 addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventTouchDown];
    self.button3.tag = 3;
    [self.mainButtonsView addSubview:self.button3];

    self.button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button4.tintColor = [UIColor whiteColor];
    [self.button4 setTitle:NSLocalizedString(@"Infos", @"Tab Title") forState:UIControlStateNormal];
    [self.button4 addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventTouchDown];
    self.button4.tag = 4;
    [self.mainButtonsView addSubview:self.button4];

    self.secondaryButton1 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.secondaryButton1.tintColor = [UIColor whiteColor];
    [self.secondaryButton1 setTitle:NSLocalizedString(@"Canteens", @"Tab Title") forState:UIControlStateNormal];
    [self.secondaryButton1 addTarget:self
                              action:@selector(switchSecondaryView:)
                    forControlEvents:UIControlEventTouchDown];
    self.secondaryButton1.tag = 1;
    [self.secondaryButtonsView addSubview:self.secondaryButton1];

    self.secondaryButton2 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.secondaryButton2.tintColor = [UIColor whiteColor];
    [self.secondaryButton2 setTitle:NSLocalizedString(@"About", @"Tab Title") forState:UIControlStateNormal];
    [self.secondaryButton2 addTarget:self
                              action:@selector(switchSecondaryView:)
                    forControlEvents:UIControlEventTouchDown];
    self.secondaryButton2.tag = 2;
    [self.secondaryButtonsView addSubview:self.secondaryButton2];
}

/**
 *  More ugly code to add separators
 */
- (void)addSomeLines
{

    self.line1 = [UIView new];
    self.line1.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
    [self.mainButtonsView addSubview:self.line1];

    self.line2 = [UIView new];
    self.line2.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
    [self.mainButtonsView addSubview:self.line2];

    self.line3 = [UIView new];
    self.line3.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
    [self.mainButtonsView addSubview:self.line3];

    self.secondaryLine1 = [UIView new];
    self.secondaryLine1.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
    [self.secondaryButtonsView addSubview:self.secondaryLine1];

    self.secondaryLine2 = [UIView new];
    self.secondaryLine2.backgroundColor = [UIColor colorWithWhite:1.0f alpha:lineAlpha];
    [self.secondaryButtonsView addSubview:self.secondaryLine2];
}

- (void)setMensen:(NSArray *)mensen
{

    _mensen = mensen;

    NSInteger extra = [[NSUserDefaults standardUserDefaults] boolForKey:@"showGame"];
    self.pageControl.numberOfPages = mensen.count + 1 + extra;

    for(UILabel *label in self.titleLabels)
    {
        [label removeFromSuperview];
    }
    for(UIImageView *imgv in self.headerImages)
    {
        [imgv.superview removeFromSuperview];
    }

    self.titleLabels = [NSMutableArray array];
    self.headerImages = [NSMutableArray array];

    for(NSDictionary *mensa in mensen)
    {
        UILabel *label = [UILabel new];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            label.font = [UIFont boldSystemFontOfSize:30];
        }
        else
        {
            label.font = [UIFont boldSystemFontOfSize:25];
        }
        label.text = mensa[@"name"];
        label.textColor = [UIColor whiteColor];
        [label addShadow];

        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:label];
        [self.titleLabels addObject:label];

        UIView *imageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];

        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        [imageContainer addSubview:imageView];

        [self.contentView addSubview:imageContainer];
        [imageView setImageWithURL:[NSURL URLWithString:mensa[@"image_url"]]];
        [self.headerImages addObject:imageView];

        UIView *ringContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        ringContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |
                                         UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }

    UILabel *label = [UILabel new];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        label.font = [UIFont boldSystemFontOfSize:30];
    }
    else
    {
        label.font = [UIFont boldSystemFontOfSize:25];
    }
    label.text = NSLocalizedString(@"Settings", @"Settings View Title");
    label.textColor = [UIColor whiteColor];
    label.layer.shouldRasterize = YES;
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOpacity = 0.3f;
    label.layer.shadowRadius = 0.5;
    label.layer.shadowOffset = CGSizeZero;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:label];
    [self.titleLabels addObject:label];

    UIView *imageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [imageContainer addSubview:imageView];
    [self.contentView addSubview:imageContainer];
    //    [imageView setImageWithURL:[NSURL URLWithString:mensa[@"image_url"]]];
    [imageView setImage:[UIImage imageNamed:@"Background"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //    [imageView setImageWithURL:[NSURL URLWithString:mensen.lastObject[@"image_url"]]];

    [self.headerImages addObject:imageView];

    [self setNeedsLayout];
}

- (void)setPosition:(float)position
{
    _position = position;

    self.pageControl.currentPage = round(position);

    [self setNeedsLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(point.y < self.frame.size.height - 30)
    {
        return NO;
    }
    return [super pointInside:point withEvent:event];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return CGSizeMake(size.width, 190.0f);
    }
    else
    {
        return CGSizeMake(size.width, 130.0f);
    }
}

- (void)layoutSubviews
{
    self.bottomLine.frame =
        CGRectMake(0, self.frame.size.height - 0.5f, self.frame.size.width, 1.0f / [UIScreen mainScreen].scale);

    CGFloat imgx = 15, imgy = 28, imgs = 70, lblh = 30.0f, lbly = 38.0f;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        imgx += 150;
        imgy += 10;
        imgs += 30;
        lblh = 50;
        lbly += 10.0f;
    }

    for(NSInteger i = 0; i < self.titleLabels.count; i++)
    {
        UILabel *label = self.titleLabels[i];
        label.frame = CGRectMake(90.0f + ((float)i - _position) * 15.0f, lbly, self.frame.size.width - 100.0, lblh);
        label.alpha = pow(1.0f - fabs(((float)i - _position)), 5);

        UIImageView *imgv = self.headerImages[i];
        imgv.transform = CGAffineTransformIdentity;

        imgv.frame = CGRectMake(0, 0, imgs, imgs);
        imgv.superview.frame = CGRectMake(imgx + sin(((float)i - _position) * M_PI) * imgs / 2.0f, imgy, imgs, imgs);
        imgv.alpha = 1.0f - pow(fabs(((float)i - _position)), 5);
        CGFloat s = 1.0f - pow(fabs(((float)i - _position)), 5);
        imgv.transform = CGAffineTransformMakeScale(s, s);

        imgv.superview.layer.zPosition = s;

        imgv.clipsToBounds = YES;

        imgv.layer.cornerRadius = imgs / 2.0f;
        imgv.layer.borderColor = [UIColor whiteColor].CGColor;
        imgv.layer.borderWidth = 1;
        imgv.superview.layer.shadowColor = [UIColor blackColor].CGColor;
        imgv.superview.layer.shadowOpacity = 0.3;
        imgv.superview.layer.shadowOffset =
            CGSizeMake(sin(((float)i - _position) * M_PI) * 1.0f * pow(1.0f - fabs(((float)i - _position)), 4),
                       pow(1.0f - fabs(((float)i - _position)), 2));
        imgv.superview.layer.shadowRadius = 0;

        imgv.contentMode = UIViewContentModeScaleAspectFill;
    }

    CGFloat buttonsHeight = 25.0f;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        buttonsHeight = 35.0f;
        self.pageControl.frame = CGRectMake(90.0f, 87.0f, self.frame.size.width - 100.0f, 30.0f);
    }
    else
    {
        self.pageControl.frame = CGRectMake(90.0f, 67.0f, self.frame.size.width - 100.0f, 30.0f);
    }
    self.mainButtonsView.frame =
        CGRectMake(MIN(0.0f, ((float)self.mensen.count - _position - 1.0f)) * self.frame.size.width,
                   self.frame.size.height - buttonsHeight - 0.5f, self.frame.size.width, buttonsHeight);
    self.secondaryButtonsView.frame =
        CGRectMake(MAX(0.0f, ((float)self.mensen.count - _position)) * self.frame.size.width,
                   self.frame.size.height - buttonsHeight - 0.5f, self.frame.size.width, buttonsHeight);

    self.button1.frame = CGRectMake(0, 0, self.frame.size.width * 0.25, self.mainButtonsView.frame.size.height);
    self.button2.frame = CGRectMake(self.frame.size.width * 0.25, 0, self.frame.size.width * 0.25,
                                    self.mainButtonsView.frame.size.height);
    self.button3.frame = CGRectMake(self.frame.size.width * 0.5, 0, self.frame.size.width * 0.25,
                                    self.mainButtonsView.frame.size.height);
    self.button4.frame = CGRectMake(self.frame.size.width * 0.75, 0, self.frame.size.width * 0.25,
                                    self.mainButtonsView.frame.size.height);

    self.secondaryButton1.frame = CGRectMake(0, 0, self.frame.size.width * 0.5, self.mainButtonsView.frame.size.height);
    self.secondaryButton2.frame =
        CGRectMake(self.frame.size.width * 0.5, 0, self.frame.size.width * 0.5, self.mainButtonsView.frame.size.height);

    self.line1.frame =
        CGRectMake(roundf(self.frame.size.width * 0.25f), 0, 0.5, self.mainButtonsView.frame.size.height);
    self.line2.frame = CGRectMake(roundf(self.frame.size.width * 0.5f), 0, 0.5, self.mainButtonsView.frame.size.height);
    self.line3.frame =
        CGRectMake(roundf(self.frame.size.width * 0.75f), 0, 0.5, self.mainButtonsView.frame.size.height);
    self.secondaryLine1.frame =
        CGRectMake(roundf(self.frame.size.width * 0.5), 0, 0.5, self.mainButtonsView.frame.size.height);

    self.mainSelection.frame =
        CGRectMake((self.mainTypeIndex - 1.0) * self.frame.size.width * 0.25,
                   self.mainButtonsView.frame.size.height - 2.0f, self.frame.size.width * 0.25, 2.0f);
    self.secondarySelection.frame =
        CGRectMake((self.secondaryTypeIndex - 1.0) * self.frame.size.width * 0.5,
                   self.mainButtonsView.frame.size.height - 2.0f, self.frame.size.width * 0.5, 2.0f);
}

- (void)switchView:(UIButton *)sender
{
    self.mainTypeIndex = sender.tag;
}
- (void)switchSecondaryView:(UIButton *)sender
{
    self.secondaryTypeIndex = sender.tag;
}

- (void)setMainTypeIndex:(NSUInteger)mainTypeIndex
{

    _mainTypeIndex = mainTypeIndex;

    self.button1.alpha = self.button2.alpha = self.button3.alpha = self.button4.alpha = 0.5;
    [self.button1 removeShadow];
    [self.button2 removeShadow];
    [self.button3 removeShadow];
    [self.button4 removeShadow];

    switch(mainTypeIndex)
    {
        case 1:
            self.button1.alpha = 1;
            [self.button1 addShadow];
            break;

        case 2:
            self.button2.alpha = 2;
            [self.button2 addShadow];
            break;

        case 3:
            self.button3.alpha = 3;
            [self.button3 addShadow];
            break;

        case 4:
            self.button4.alpha = 4;
            [self.button4 addShadow];
            break;

        default:
            break;
    }

    [self setNeedsLayout];
}

- (void)setSecondaryTypeIndex:(NSUInteger)secondaryTypeIndex
{

    _secondaryTypeIndex = secondaryTypeIndex;

    self.secondaryButton1.alpha = self.secondaryButton2.alpha = 0.5;
    [self.secondaryButton1 removeShadow];
    [self.secondaryButton2 removeShadow];

    switch(secondaryTypeIndex)
    {
        case 1:
            self.secondaryButton1.alpha = 1;
            [self.secondaryButton1 addShadow];
            break;

        case 2:
            self.secondaryButton2.alpha = 2;
            [self.secondaryButton2 addShadow];
            break;

        default:
            break;
    }

    [self setNeedsLayout];
}

@end
