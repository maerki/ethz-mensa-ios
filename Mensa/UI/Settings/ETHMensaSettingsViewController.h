//
//  ETHMensaSettingsViewController.h
//  Mensa
//
//  Created by Nicolas Märki on 18.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETHMensaSettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (nonatomic) NSUInteger secondaryTypeIndex;

@property (nonatomic, strong) UITableView *tableView;

@end
