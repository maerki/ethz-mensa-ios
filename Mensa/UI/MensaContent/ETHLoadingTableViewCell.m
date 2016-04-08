//
//  ETHLoadingTableViewCell.m
//  Mensa
//
//  Created by Nicolas Märki on 12.08.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHLoadingTableViewCell.h"

@interface ETHLoadingTableViewCell ()

@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UILabel *label;

@end

@implementation ETHLoadingTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    self.aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.contentView addSubview:self.aiv];
    [self.aiv startAnimating];

    self.label = [UILabel new];
    [self.contentView addSubview:self.label];
    self.label.textColor = [UIColor whiteColor];
    self.label.numberOfLines = 0;
    self.label.textAlignment = NSTextAlignmentCenter;

    return self;
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    [self update];
}

- (void)setError:(NSError *)error
{
    _error = error;
    [self update];
}

- (void)setHasAbend:(BOOL)hasAbend
{
    _hasAbend = hasAbend;
    [self update];
}

- (void)setWeekend:(BOOL)weekend
{
    _weekend = weekend;
    [self update];
}

- (void)update
{

    self.aiv.hidden = !_loading;
    self.label.hidden = _loading;

    if(_error)
    {
        self.label.text = _error.localizedDescription;
    }
    else if(_weekend)
    {
        self.label.text =
            NSLocalizedString(@"WOCHENENDE! Kennst du?\nMensa-Menüs sollten dich heute wirklich nicht interessieren.", nil);
    }
    else if(!_hasAbend)
    {
        self.label.text = NSLocalizedString(@"Diese Mensa hat keine Abend-Menüs", nil);
    }
    else
    {
        self.label.text = NSLocalizedString(@"Keine Menüs gefunden", nil);
    }
}

- (void)layoutSubviews
{
    self.aiv.frame =
        CGRectMake(self.frame.size.width / 2.0 - self.aiv.frame.size.width / 2.0, self.frame.size.height / 2.0 - 30.0,
                   self.aiv.frame.size.width, self.aiv.frame.size.height - 20);
    self.label.frame = CGRectMake(10, 10, self.frame.size.width - 20, self.frame.size.height - 110);
}

@end
