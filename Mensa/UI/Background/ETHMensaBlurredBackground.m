//
//  ETHMensaBlurredBackground.m
//  Campus
//
//  Created by Nicolas Märki on 08.11.13.
//  Copyright (c) 2013 Nicolas Märki. All rights reserved.
//

#import "ETHMensaBlurredBackground.h"

#import "AFNetworking.h"

#import "UIImage+ImageEffects.h"

@interface ETHMensaBlurredBackground ()

@property (nonatomic, strong) NSMutableDictionary *images;

@property (nonatomic, strong) UIImageView *leftImageView, *rightImageView;
@property (nonatomic, strong) UIImage *settingsImage;

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

@end

@implementation ETHMensaBlurredBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {

        self.backgroundColor = [UIColor blackColor];

        self.leftImageView = [UIImageView new];
        [self addSubview:self.leftImageView];
        self.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.leftImageView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];

        self.rightImageView = [UIImageView new];
        [self addSubview:self.rightImageView];
        self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.rightImageView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];

        self.images = [NSMutableDictionary dictionary];

        UIView *particleLayerView =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        particleLayerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:particleLayerView];

        self.settingsImage = [UIImage imageNamed:@"Background"];
        //        UIColor *tintColor = [UIColor colorWithWhite:0.7 alpha:0.2];
        //        self.settingsImage =
        //            [self.settingsImage applyBlurWithRadius:15 tintColor:tintColor saturationDeltaFactor:1.8
        // maskImage:nil];
        //        self.settingsImage =
        //            [self.settingsImage applyBlurWithRadius:35 tintColor:tintColor saturationDeltaFactor:1.8
        // maskImage:nil];

        //        self.emitterLayer = [CAEmitterLayer layer];
        //        [particleLayerView.layer addSublayer:self.emitterLayer];
        //
        //        self.emitterLayer.emitterShape = @"line";
        //        self.emitterLayer.emitterSize = CGSizeMake(frame.size.width, frame.size.height);
        //
        //        CAEmitterCell *fire = [CAEmitterCell emitterCell];
        //        fire.birthRate = 20;
        //        fire.lifetime = 30.0;
        //        fire.lifetimeRange = 0.5;
        ////        fire.color = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.01] CGColor];
        //        fire.velocity = 10;
        //        fire.velocityRange = 20;
        //        fire.emissionLatitude = 1;
        ////        fire.alphaSpeed = -0.3;
        //        fire.scale = 3.0;
        //        fire.scaleSpeed = -0.4;
        //        fire.contents = (id)[[UIImage imageNamed:@"Sphere.png"] CGImage];
        //        [fire setName:@"fire"];
        //
        //        self.emitterLayer.emitterCells = [NSArray arrayWithObject:fire];
    }
    return self;
}

- (void)setMensen:(NSArray *)mensen
{
    _mensen = mensen;

    NSMutableArray *mutableOperations = [NSMutableArray array];

    for(NSDictionary *mensaDict in mensen)
    {
        NSString *imageUrl = mensaDict[@"image_url"];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imageFile =
            [documentsDirectory stringByAppendingFormat:@"/%@-%@", mensaDict[@"id"], [imageUrl lastPathComponent]];

        NSData *data = [NSData dataWithContentsOfFile:imageFile];

        // data = nil;

        if(data)
        {
            UIImage *responseObject = [UIImage imageWithData:data];
            self.images[imageUrl] = responseObject;
            self.position = self.position;
        }
        else
        {

            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                                     cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                 timeoutInterval:60];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = [AFImageResponseSerializer serializer];

            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *responseObject)
                                                     {

                CGSize size;
                size.width = 200.0f;
                size.height = responseObject.size.height / responseObject.size.width * size.width;
                UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                [responseObject drawInRect:CGRectMake(0, 0, size.width, size.height)];
                responseObject = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                UIColor *tintColor = [UIColor colorWithWhite:0.7 alpha:0.2];
                responseObject =
                    [responseObject applyBlurWithRadius:15 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
                responseObject =
                    [responseObject applyBlurWithRadius:35 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];

                [UIImagePNGRepresentation(responseObject) writeToFile:imageFile atomically:YES];
                self.images[imageUrl] = responseObject;
                self.position = self.position;
            }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                        {
                    UIImage *responseObject = [UIImage imageNamed:@"Background"];
                    responseObject = [responseObject applyLightEffect];
                    self.images[imageUrl] = responseObject;
                    self.position = self.position;
                }];

            [mutableOperations addObject:operation];
        }
    }

    [[NSOperationQueue mainQueue] addOperations:mutableOperations waitUntilFinished:NO];
}

- (void)setPosition:(float)position
{
    int leftIndex = MAX(0, MIN(self.mensen.count, floorf(position)));
    int rightIndex = MAX(0, MIN(self.mensen.count, floorf(position) + 1));
    if(leftIndex == self.mensen.count)
    {
        self.leftImageView.image = self.settingsImage;
    }
    else
    {
        self.leftImageView.image = self.images[self.mensen[leftIndex][@"image_url"]];
    }
    if(rightIndex == self.mensen.count)
    {
        self.rightImageView.image = self.settingsImage;
    }
    else
    {
        self.rightImageView.image = self.images[self.mensen[rightIndex][@"image_url"]];
    }
    if(position < 0)
    {
        self.leftImageView.alpha = 1.0f + position;
    }
    else
    {
        self.leftImageView.alpha = 1.0f + (float)rightIndex - position;
    }
    //    if(floorf(position) + 1 >= self.mensen.count)
    //    {
    //        self.rightImageView.alpha = 1.0f - (position - (float)leftIndex);
    //    }
    //    else
    //    {
    self.rightImageView.alpha = position - (float)leftIndex;
    //    }

    _position = position;
}

- (void)layoutSubviews
{
    self.leftImageView.frame = CGRectInset(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), -100, -100);
    self.rightImageView.frame =
        CGRectInset(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), -100, -100);

    self.emitterLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.emitterLayer.emitterPosition = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height);
}

@end
