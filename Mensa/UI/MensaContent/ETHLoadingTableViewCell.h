//
//  ETHLoadingTableViewCell.h
//  Mensa
//
//  Created by Nicolas Märki on 12.08.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETHLoadingTableViewCell : UICollectionViewCell

@property (nonatomic, strong) NSError *error;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL hasAbend;
@property (nonatomic) BOOL weekend;

@end
