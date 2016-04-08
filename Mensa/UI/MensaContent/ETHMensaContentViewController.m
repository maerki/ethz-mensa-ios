//
//  ETHMensaContentScrollView.m
//  Mensa
//
//  Created by Nicolas Märki on 11.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaContentViewController.h"

#import "ETHMensaMenuCell.h"
#import "ETHMensaWeekMenuCell.h"
#import "ETHMensaSectionHeaderView.h"
#import "ETHMensaMapCell.h"
#import "ETHMensaWebcamCell.h"
#import "ETHLoadingTableViewCell.h"
#import "ETHImageViewController.h"
#import "ETHMensaAppDelegate.h"

@interface ETHMensaContentViewController ()

@property (nonatomic, strong) UICollectionViewLayout *layout;

@property (nonatomic, strong) NSMutableDictionary *shareImageMenu;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSDateFormatter *inFormatter, *outFormatter;

@property (nonatomic) BOOL weekend;
@property (nonatomic) NSInteger weekday;

@end

@implementation ETHMensaContentViewController

- (id)init
{

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 00.0f;

    self = [super initWithCollectionViewLayout:layout];

    self.layout = layout;

    _mensaIndex = -1;
    _mainTypeIndex = 1;

    self.inFormatter = [NSDateFormatter new];
    self.inFormatter.dateFormat = @"YYYY-MM-dd";

    self.outFormatter = [NSDateFormatter new];
    self.outFormatter.dateFormat =
        [NSDateFormatter dateFormatFromTemplate:@"EEEE, ddMMYYYY" options:0 locale:[NSLocale currentLocale]];

    return self;
}

- (void)viewDidLoad
{

    self.collectionView.backgroundColor = [UIColor clearColor];

    self.collectionView.showsVerticalScrollIndicator = NO;

    [self.collectionView registerClass:[ETHMensaMenuCell class] forCellWithReuseIdentifier:@"MenuCell"];
    [self.collectionView registerClass:[ETHMensaWeekMenuCell class] forCellWithReuseIdentifier:@"WeekMenuCell"];
    [self.collectionView registerClass:[ETHMensaMapCell class] forCellWithReuseIdentifier:@"MapCell"];
    [self.collectionView registerClass:[ETHMensaWebcamCell class] forCellWithReuseIdentifier:@"WebcamCell"];
    [self.collectionView registerClass:[ETHLoadingTableViewCell class] forCellWithReuseIdentifier:@"LoadingCell"];

    [self.collectionView registerClass:[ETHMensaSectionHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"HeaderCell"];
    [self.collectionView registerClass:[ETHMensaSectionHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:@"FooterCell"];

    self.collectionView.alwaysBounceVertical = YES;
}



- (void)loadMenus:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ETHMensaLoadMenus" object:nil];
}

- (void)setMensaIndex:(NSUInteger)mensaIndex
{

    if(mensaIndex != _mensaIndex)
    {
        _mensaIndex = mensaIndex;
        //        [self updateGameState];

        self.weekend =
            ([[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]].weekday % 7) <= 1;

        self.weekday = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]].weekday;

        [[NSNotificationCenter defaultCenter]
            addObserverForName:@"ETHMensaDidUpdateMenus"
                        object:nil
                         queue:[NSOperationQueue currentQueue]
                    usingBlock:^(NSNotification *note)
                               {

                        self.weekend =
                            ([[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]]
                                 .weekday %
                             7) <= 1;

                        self.weekday =
                            [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]]
                                .weekday;

                        if([note.object[@"id"] intValue] == [self.mensa[@"id"] intValue])
                        {
                            [self.collectionView reloadData];
                        }
                    }];
    }
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.contentOffset = CGPointMake(0, [self.mensa[@"contentOffset"] floatValue]);

    [self.collectionView reloadData];

    [self scrollWeekToCurrent];
}

- (BOOL)hasContent
{
    switch(self.mainTypeIndex)
    {
        case 1:
            return [self.mensa[@"lunchMenus"] count] > 0;
        case 2:
            return [self.mensa[@"eveningMenus"] count] > 0;

        case 3:
            //            if(section % 2 == 0)
            //            {
            //                return MAX(1,[self.mensa[@"weekMenus"][section / 2][@"lunch"] count]);
            //            }
            //            else
            //            {
            //                return [self.mensa[@"weekMenus"][section / 2][@"evening"] count];
            //            }
            return YES;

        case 4:
            return YES;
        default:
            return 0;
    }
}

- (void)setMainTypeIndex:(NSUInteger)mainTypeIndex
{
    _mainTypeIndex = mainTypeIndex;

    self.collectionView.contentOffset = CGPointMake(0, 0);
    self.mensa[@"contentOffset"] = @0;

    [self.collectionView reloadData];

    [self scrollWeekToCurrent];

    //[self updateGameState];
}

- (void)scrollWeekToCurrent
{
    if(self.mainTypeIndex == 3 &&
       [self.collectionView numberOfItemsInSection:MAX(0, ((self.weekday - 1) % 6 - 1) * 2)] > 0)
    {
        [self.collectionView
            scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:MAX(0, ((self.weekday - 1) % 6 - 1) * 2)]
                   atScrollPosition:UICollectionViewScrollPositionTop
                           animated:NO];
        self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentOffset.y - 42);
    }
}

//- (void)updateGameState {
//
//    BOOL showGame = NO;
//    showGame |= (![self.mensa[@"loadingDay"] boolValue] && self.mainTypeIndex == 1 && [self.mensa[@"lunchMenus"]
// count] == 0);
//    showGame |= (![self.mensa[@"loadingDay"] boolValue] && self.mainTypeIndex == 2 && [self.mensa[@"eveningMenus"]
// count] == 0);
//    showGame &= self.mensa != nil;
//    if (showGame) {
//        if (!self.gameViewController) {
//            self.gameViewController = [ETHMensaGameViewController new];
//            [self addChildViewController:self.gameViewController];
//        }
//        [self.view addSubview:self.gameViewController.view];
//        [self.view setNeedsLayout];
//    }
//    else {
//        [self.gameViewController.view removeFromSuperview];
//    }
//
//}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.mensa[@"contentOffset"] = @(scrollView.contentOffset.y);

    [[NSNotificationCenter defaultCenter] postNotificationName:@"pullDown"
                                                        object:self
                                                      userInfo:@{@"offset": @(scrollView.contentOffset.y)}];
}

- (NSMutableDictionary *)mensa
{
    if(_mensaIndex >= self.mensen.count)
    {
        return nil;
    }
    return self.mensen[self.mensaIndex];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    switch(self.mainTypeIndex)
    {
        case 1:
        case 2:
            return 1;

        case 3:
            return 10;

        case 4:
            if(self.mensa)
                return 3;
            else
                return 0;
        default:
            return 0;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch(self.mainTypeIndex)
    {
        case 1:
            return MAX(1, [self.mensa[@"lunchMenus"] count]);
        case 2:
            return MAX(1, [self.mensa[@"eveningMenus"] count]);

        case 3:
            if(section % 2 == 0)
            {
                return MAX(1, [self.mensa[@"weekMenus"][section / 2][@"lunch"] count]);
            }
            else
            {
                return [self.mensa[@"weekMenus"][section / 2][@"evening"] count];
            }

        case 4:
            if(section == 0)
            {
                if([self.mensa[@"webcam_url2"] length])
                {
                    return 2;
                }
                else if([self.mensa[@"webcam_url"] length])
                {
                    return 1;
                }

                return 0;
            }
            else if(section == 1)
            {
                return 6;
            }
            else
            {
                return 1;
            }
        default:
            return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    switch(self.mainTypeIndex)
    {
        case 1:
        {
            ETHMensaMenuCell *cell =
                [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
            if(indexPath.row == [self.mensa[@"lunchMenus"] count])
            {
                ETHLoadingTableViewCell *loadingCell =
                    [collectionView dequeueReusableCellWithReuseIdentifier:@"LoadingCell" forIndexPath:indexPath];
                loadingCell.loading = !self.mensa || [self.mensa[@"loadingDay"] boolValue];
                loadingCell.error = self.mensa[@"dayLoadingError"];
                loadingCell.hasAbend = YES;
                loadingCell.weekend = self.weekend;
                return loadingCell;
            }
            cell.menu = self.mensa[@"lunchMenus"][indexPath.row];
            cell.mensa = self.mensa;
            cell.delegate = self;
            return cell;
        }

        case 2:
        {
            ETHMensaMenuCell *cell =
                [collectionView dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
            if(indexPath.row == [self.mensa[@"eveningMenus"] count])
            {
                ETHLoadingTableViewCell *loadingCell =
                    [collectionView dequeueReusableCellWithReuseIdentifier:@"LoadingCell" forIndexPath:indexPath];
                loadingCell.loading = [self.mensa[@"loadingDay"] boolValue];
                loadingCell.error = self.mensa[@"dayLoadingError"];
                loadingCell.hasAbend = [self.mensa[@"has_abend"] boolValue];
                loadingCell.weekend = self.weekend;
                return loadingCell;
            }
            cell.menu = self.mensa[@"eveningMenus"][indexPath.row];
            cell.mensa = self.mensa;
            cell.delegate = self;
            return cell;
        }

        case 3:
        {
            ETHMensaWeekMenuCell *cell =
                [collectionView dequeueReusableCellWithReuseIdentifier:@"WeekMenuCell" forIndexPath:indexPath];
            if(indexPath.section % 2 == 0)
            {
                cell.menu = self.mensa[@"weekMenus"][indexPath.section / 2][@"lunch"][indexPath.row];
            }
            else
            {
                cell.menu = self.mensa[@"weekMenus"][indexPath.section / 2][@"evening"][indexPath.row];
            }
            cell.past = (indexPath.section / 2) < self.weekday - 2;
            return cell;
        }

        case 4:
        {
            if(indexPath.section == 0)
            {
                ETHMensaWebcamCell *cell =
                    [collectionView dequeueReusableCellWithReuseIdentifier:@"WebcamCell" forIndexPath:indexPath];
                cell.url = indexPath.row == 0 ? self.mensa[@"webcam_url"] : self.mensa[@"webcam_url2"];
                return cell;
            }
            else if(indexPath.section == 1)
            {
                ETHMensaWeekMenuCell *cell =
                    [collectionView dequeueReusableCellWithReuseIdentifier:@"WeekMenuCell" forIndexPath:indexPath];
                cell.menu = [self menuDictForInfo:indexPath.row];
                cell.past = NO;
                return cell;
            }
            else
            {
                ETHMensaMapCell *cell =
                    [collectionView dequeueReusableCellWithReuseIdentifier:@"MapCell" forIndexPath:indexPath];
                cell.mensa = [self mensa];
                return cell;
            }
        }

        default:
            return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch(self.mainTypeIndex)
    {
        case 1:
            if(indexPath.row == [self.mensa[@"lunchMenus"] count])
            {
                return CGRectInset(collectionView.frame, 10, 20).size;
            }
            return [ETHMensaMenuCell sizeWithItem:self.mensa[@"lunchMenus"][indexPath.row]
                                       parentSize:collectionView.frame.size];

        case 2:
            if(indexPath.row == [self.mensa[@"eveningMenus"] count])
            {
                return CGRectInset(collectionView.frame, 10, 20).size;
            }
            return [ETHMensaMenuCell sizeWithItem:self.mensa[@"eveningMenus"][indexPath.row]
                                       parentSize:collectionView.frame.size];

        case 3:
            if(indexPath.row >= [self.mensa[@"weekMenus"] count] + [self.mensa[@"weekMenus"] count])
            {
                return CGRectInset(collectionView.frame, 10, 20).size;
            }
            if(indexPath.section % 2 == 0)
            {
                return [ETHMensaWeekMenuCell
                    sizeWithItem:self.mensa[@"weekMenus"][indexPath.section / 2][@"lunch"][indexPath.row]
                      parentSize:collectionView.frame.size];
            }
            else
            {
                return [ETHMensaWeekMenuCell
                    sizeWithItem:self.mensa[@"weekMenus"][indexPath.section / 2][@"evening"][indexPath.row]
                      parentSize:collectionView.frame.size];
            }

        case 4:
            if(indexPath.section == 0)
            {
                return CGSizeMake(320, 250);
            }
            else if(indexPath.section == 1)
            {
                return [ETHMensaWeekMenuCell sizeWithItem:[self menuDictForInfo:indexPath.row]
                                               parentSize:collectionView.frame.size];
            }
            else
            {
                return CGSizeMake(320, 278);
            }

        default:
            return CGSizeZero;
    }
}

- (NSDictionary *)menuDictForInfo:(NSInteger)row
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    switch(row)
    {
        case 0:
            dict[@"name"] = NSLocalizedString(@"Opening Times", @"Info Title");
            dict[@"menu"] = self.mensa[@"openingTimes"];
            break;

        case 1:
            dict[@"name"] = NSLocalizedString(@"Did you know?", @"Info Title");
            dict[@"menu"] = self.mensa[@"news"];
            break;

        case 2:
            dict[@"name"] = NSLocalizedString(@"Caterer", @"Info Title");
            dict[@"menu"] = self.mensa[@"caterer"];
            break;

        case 3:
            dict[@"name"] = NSLocalizedString(@"Employees", @"Info Title");
            dict[@"menu"] = self.mensa[@"mitarbeitende"];
            break;

        case 4:
            dict[@"name"] = NSLocalizedString(@"Seats", @"Info Title");
            dict[@"menu"] = self.mensa[@"sitzplaetze"];
            break;

        case 5:
            dict[@"name"] = NSLocalizedString(@"Meals per Day", @"Info Title");
            dict[@"menu"] = self.mensa[@"essenprotag"];
            break;

        default:
            break;
    }

    return dict;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section
{
    if(self.mainTypeIndex == 3)
    {
        if(section % 2 == 1 && [self.mensa[@"weekMenus"][0][@"evening"] count] == 0)
        {
            return CGSizeZero;
        }
        return CGSizeMake(collectionView.frame.size.width, 40);
    }
    return CGSizeMake(collectionView.frame.size.width, 15);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{

    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        ETHMensaSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                               withReuseIdentifier:@"HeaderCell"
                                                                                      forIndexPath:indexPath];
        header.titleLabel.text = [self dateStringInSection:indexPath.section];
        if(self.mainTypeIndex == 3 && indexPath.section / 2 < self.weekday - 2)
        {
            header.titleLabel.alpha = 0.5;
        }
        else
        {
            header.titleLabel.alpha = 1.0f;
        }
        return header;
    }
    else
    {
        ETHMensaSectionHeaderView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                               withReuseIdentifier:@"FooterCell"
                                                                                      forIndexPath:indexPath];
        footer.titleLabel.text = nil;
        return footer;
    }
}

- (NSString *)dateStringInSection:(NSInteger)section
{
    switch(self.mainTypeIndex)
    {
        case 1:
            return nil;
        //            return [self.outFormatter
        //                stringFromDate:[self.inFormatter dateFromString:self.mensa[@"lunchMenus"][0][@"date"]]];

        case 3:
            if([self.mensa[@"weekMenus"][0][@"evening"] count] == 0)
            {
                return [self.outFormatter
                    stringFromDate:[self.inFormatter
                                       dateFromString:self.mensa[@"weekMenus"][section / 2][@"lunch"][0][@"date"]]];
            }
            else if(section % 2 == 0)
            {
                return [[self.outFormatter
                    stringFromDate:[self.inFormatter
                                       dateFromString:self.mensa[@"weekMenus"][section / 2][@"lunch"][0][@"date"]]]
                    stringByAppendingString:NSLocalizedString(@", Mittag", nil)];
            }
            else
            {
                return [[self.outFormatter
                    stringFromDate:[self.inFormatter
                                       dateFromString:self.mensa[@"weekMenus"][section / 2][@"lunch"][0][@"date"]]]
                    stringByAppendingString:NSLocalizedString(@", Abend", nil)];
            }

        default:
            return nil;
    }
}

#pragma mark - Menu Actions

- (void)likeMenu:(NSMutableDictionary *)menu
{

    if([menu[@"userLiked"] boolValue] == NO)
    {
        menu[@"userLiked"] = @(YES);
        menu[@"likes"] = @([menu[@"likes"] intValue] + 1);
    }
    else
    {
        menu[@"userLiked"] = @(NO);
        menu[@"likes"] = @([menu[@"likes"] intValue] - 1);
    }

    [self.collectionView reloadData];

    [ETHBackend loadAction:@"mensaLike"
                    params:@
                    {
                        @"menu": menu[@"id"],
                        @"likes": menu[@"userLiked"]
                    }
                    method:@"POST"
                  complete:^(id result, NSError *error) {}];
}

#pragma mark - Upload Image

- (void)shareImage:(NSMutableDictionary *)menu
{

    self.shareImageMenu = menu;

    UIActionSheet *activitySheet = [[UIActionSheet alloc]
                 initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Bild für Menu '%@'", nil), menu[@"name"]]
                      delegate:self
             cancelButtonTitle:nil
        destructiveButtonTitle:nil
             otherButtonTitles:nil];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [activitySheet addButtonWithTitle:NSLocalizedString(@"Kamera", @"Image Source Type")];
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [activitySheet addButtonWithTitle:NSLocalizedString(@"Fotos", @"Image Source Type")];
    }

    activitySheet.cancelButtonIndex = [activitySheet addButtonWithTitle:NSLocalizedString(@"Abbrechen", nil)];

    [activitySheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    UIImagePickerController *controller = [[UIImagePickerController alloc] init];

    if(buttonIndex == 0)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else
        {
            return;
        }
    }
    else if(buttonIndex == 1)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }

        else
        {
            return;
        }
    }
    else
    {
        return;
    }

    controller.allowsEditing = YES;

    controller.delegate = self;

    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = info[UIImagePickerControllerEditedImage];

    UIGraphicsBeginImageContext(CGSizeMake(640, img.size.height * 640 / img.size.width));
    [img drawInRect:CGRectMake(0, 0, 640, img.size.height * 640 / img.size.width)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self.shareImageMenu[@"images"] addObject:[@
                                                  {
                                                      @"loading": @YES
                                                  } mutableCopy]];

    [self.collectionView reloadData];

    NSData *data = UIImageJPEGRepresentation(img, 0.7);
    NSDictionary *params = @{@"menu": self.shareImageMenu[@"id"]};

    [ETHBackend uploadAction:@"mensaImage"
                      params:params
                        data:data
                    complete:^(id result, NSError *error)
                             {
                        [self.shareImageMenu[@"images"] lastObject][@"loading"] = @NO;
                        [self.shareImageMenu[@"images"] lastObject][@"thumb"] = img;
                        [self.shareImageMenu[@"images"] lastObject][@"largeImg"] = img;
                        [self.collectionView reloadData];
                    }];
}

- (void)openImage:(NSMutableDictionary *)menu index:(NSInteger)tag
{
    ETHImageViewController *ivc = [[ETHImageViewController alloc] init];

    ETHMensaAppDelegate *appdel = (ETHMensaAppDelegate *)[UIApplication sharedApplication].delegate;
    [appdel.window.rootViewController addChildViewController:ivc];
    [appdel.window.rootViewController.view addSubview:ivc.view];
    ivc.view.frame = CGRectMake(0, 0, appdel.window.rootViewController.view.bounds.size.width,
                                appdel.window.rootViewController.view.bounds.size.height);
    ivc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [ivc openImage:menu index:tag];
}

@end
