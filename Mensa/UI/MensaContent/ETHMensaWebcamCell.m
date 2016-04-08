//
//  ETHMensaWebcamCell.m
//  Mensa
//
//  Created by Nicolas Märki on 08.06.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaWebcamCell.h"

@interface ETHMensaWebcamCell ()

@property (nonatomic, strong) UIActivityIndicatorView *aiv;

@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic) BOOL loading;

@end

@implementation ETHMensaWebcamCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.titleLabel.text = NSLocalizedString(@"Webcam", @"Webcam Title");
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, self.frame.size.width-30, self.frame.size.height-60)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        
        
        self.aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.aiv.frame = CGRectMake(CGRectGetMidX(self.imageView.frame)-self.aiv.frame.size.width/2.0f,CGRectGetMidY(self.imageView.frame)-self.aiv.frame.size.height/2.0f, self.aiv.frame.size.width, self.aiv.frame.size.height);
        [self addSubview:self.aiv];
        
        self.errorLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.imageView.frame, 20, 20)];
        self.errorLabel.font = [UIFont boldSystemFontOfSize:15];
        self.errorLabel.textColor = [UIColor whiteColor];
        [self.errorLabel addShadow];
        self.errorLabel.numberOfLines = 0;
        [self addSubview:self.errorLabel];
        
        [self addSubview:self.imageView];
        
        
    }
    return self;
}

- (void)setUrl:(NSString *)url {

    if(![url isEqualToString:_url]) {
        _url = url;
        self.imageView.image = nil;
        [self.aiv startAnimating];
        self.loading = NO;
    }
    [self loadImage];
}

- (void)loadImage {
    
    NSString *url = _url;
    
    if (self.loading) {
        return;
    }
    self.loading = YES;
    self.errorLabel.text = nil;
    [self.aiv startAnimating];
    
    [ETHBackend loadImage:url complete:^(UIImage *image, NSError *error) {
        if ([url isEqualToString:_url]) {
            self.imageView.image = image;
            [self.aiv stopAnimating];
        }
        if (error) {
            self.errorLabel.text = NSLocalizedString(@"Loading failed. Too bad... \nSome webcams are only availiable inside the ETHZ network.", @"Webcam error message");
        }
        
        self.loading = NO;
        
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
