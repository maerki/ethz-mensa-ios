//
//  ETHMensaMapCell.h
//  Mensa
//
//  Created by Nicolas Märki on 08.06.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaWeekMenuCell.h"

#import <MapKit/MapKit.h>

@interface ETHMensaMapCell : ETHMensaWeekMenuCell <MKMapViewDelegate>

@property (nonatomic, strong) NSDictionary *mensa;

@property (nonatomic, strong) UIImageView *imageView;

@end
