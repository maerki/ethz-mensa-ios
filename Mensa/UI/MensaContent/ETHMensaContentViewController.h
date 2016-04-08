//
//  ETHMensaContentScrollView.h
//  Mensa
//
//  Created by Nicolas Märki on 11.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETHMensaContentViewController
    : UICollectionViewController<UICollectionViewDelegateFlowLayout, UIActionSheetDelegate,
                                 UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) NSUInteger mensaIndex;

@property (nonatomic, strong) NSArray *mensen;

@property (nonatomic) NSUInteger mainTypeIndex;

- (void)shareImage:(NSMutableDictionary *)menu;
- (void)likeMenu:(NSMutableDictionary *)menu;
- (void)openImage:(NSMutableDictionary *)menu index:(NSInteger)tag;

@end
