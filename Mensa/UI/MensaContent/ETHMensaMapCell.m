//
//  ETHMensaMapCell.m
//  Mensa
//
//  Created by Nicolas Märki on 08.06.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaMapCell.h"

@interface ETHMensaMapCell ()



@end


@implementation ETHMensaMapCell

+ (NSMutableDictionary *)mapImages {
    static NSMutableDictionary *dict = nil;
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    return dict;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
       
        
        self.titleLabel.text = NSLocalizedString(@"Location", @"Map Title");
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, self.frame.size.width-30, self.frame.size.height-60)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        
        
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        aiv.frame = CGRectMake(CGRectGetMidX(self.imageView.frame)-aiv.frame.size.width/2.0f,CGRectGetMidY(self.imageView.frame)-aiv.frame.size.height/2.0f, aiv.frame.size.width, aiv.frame.size.height);
        [self addSubview:aiv];
        [aiv startAnimating];
        
        [self addSubview:self.imageView];
        
        
    }
    return self;
}

- (void)setMensa:(NSMutableDictionary *)mensa {
    
    if (_mensa != mensa) {
        
        
        _mensa = mensa;
        
        self.imageView.image = [ETHMensaMapCell mapImages][mensa[@"id"]];
        
        
        if (!self.imageView.image) {
            
            self.imageView.layer.borderWidth = 0;
            
            
            CLLocationDegrees lat = [mensa[@"latitude"] floatValue];
            CLLocationDegrees lon = [mensa[@"longitude"] floatValue];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
            MKCoordinateRegion region =
            MKCoordinateRegionMakeWithDistance (coordinate, self.imageView.frame.size.width*4.0, self.imageView.frame.size.height*4.0);
            
            MKMapSnapshotOptions* options = [MKMapSnapshotOptions new];
         
            options.region = region;
            
            MKMapSnapshotter* snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
            [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot* snapshot, NSError* error) {
                
                
                UIImage *image = snapshot.image;
                
                // Get the size of the final image
                
                CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
                
                // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
                
                MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
                UIImage *pinImage = pin.image;
                
                // ok, let's start to create our final image
                
                UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                
                // first, draw the image from the snapshotter
                
                [image drawAtPoint:CGPointMake(0, 0)];
                
                // now, let's iterate through the annotations and draw them, too
                
               
                    
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                [annotation setCoordinate:coordinate];
                [annotation setTitle:mensa[@"name"]];
                
                CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
                if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
                {
                    CGPoint pinCenterOffset = pin.centerOffset;
                    point.x -= pin.bounds.size.width / 2.0;
                    point.y -= pin.bounds.size.height / 2.0;
                    point.x += pinCenterOffset.x;
                    point.y += pinCenterOffset.y;
                    
                    [pinImage drawAtPoint:point];
                }
                
                
                // grab the final image
                
                UIImage *mapImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    if (self.mensa == mensa) {
                        [ETHMensaMapCell mapImages][mensa[@"id"]] = mapImage;
                        self.imageView.image = mapImage;
                        
                        
                        [self.imageView addShadow];
                    }
                    
                });
            }];
            
        }
        
    }
    
            
                      

    
    
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
