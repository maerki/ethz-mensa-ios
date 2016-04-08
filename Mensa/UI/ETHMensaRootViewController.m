//
//  MensaRootViewController.m
//  Mensa
//
//  Created by Nicolas Märki on 11.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaRootViewController.h"

#import "ETHMensaBlurredBackground.h"
#import "ETHMensaContentViewController.h"
#import "ETHMensaSettingsViewController.h"
#import "ETHMensaHeaderView.h"
#import "ETHMensaGameViewController.h"

@interface ETHMensaRootViewController ()

@property (nonatomic, strong) NSArray *allMensen;
@property (nonatomic, strong) NSArray *selectedMensen;

@property (nonatomic, strong) UIScrollView *mensenScrollView;
@property (nonatomic, strong) NSMutableArray *activeContentViewControllers;
@property (nonatomic, strong) NSMutableArray *queuedContentViewControllers;
@property (nonatomic, strong) NSMutableArray *allContentViewControllers;
@property (nonatomic, strong) ETHMensaSettingsViewController *settingsViewController;

@property (nonatomic, strong) ETHMensaHeaderView *headerView;

@property (nonatomic, strong) ETHMensaGameViewController *gameViewController;

@property (nonatomic, strong) ETHMensaBlurredBackground *blurredBackground;

@end

@implementation ETHMensaRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    background.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:background];

    self.blurredBackground = [[ETHMensaBlurredBackground alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [self.view addSubview:self.blurredBackground];

    self.mensenScrollView = [UIScrollView new];
    [self.view addSubview:self.mensenScrollView];
    self.mensenScrollView.delegate = self;
    self.mensenScrollView.scrollsToTop = NO;
    self.mensenScrollView.pagingEnabled = YES;
    self.mensenScrollView.showsVerticalScrollIndicator = NO;
    self.mensenScrollView.showsHorizontalScrollIndicator = NO;

    self.activeContentViewControllers = [NSMutableArray new];
    self.queuedContentViewControllers = [NSMutableArray new];
    self.allContentViewControllers = [NSMutableArray new];

    self.settingsViewController = [ETHMensaSettingsViewController new];
    [self addChildViewController:self.settingsViewController];
    [self.mensenScrollView addSubview:self.settingsViewController.view];
    self.settingsViewController.view.hidden = YES;

    self.gameViewController = [ETHMensaGameViewController new];
    [self addChildViewController:self.gameViewController];
    [self.mensenScrollView addSubview:self.gameViewController.view];

    self.headerView = [ETHMensaHeaderView new];
    [self.view addSubview:self.headerView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMenus:)
                                                 name:@"ETHMensaLoadMenus"
                                               object:nil];
    [self loadMensen];

    [self.headerView addObserver:self forKeyPath:@"mainTypeIndex" options:NSKeyValueObservingOptionNew context:nil];
    [self.headerView addObserver:self
                      forKeyPath:@"secondaryTypeIndex"
                         options:NSKeyValueObservingOptionNew
                         context:nil];

    [self.view layoutSubviews];

    self.headerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.mensenScrollView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.blurredBackground.alpha = 0;
    [UIView animateWithDuration:0.7
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0
                        options:0
                     animations:^
                                {
                         self.headerView.transform = CGAffineTransformIdentity;
                         self.mensenScrollView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
    [UIView animateWithDuration:1
                     animations:^
                                { self.blurredBackground.alpha = 1; }];
}

- (void)dealloc
{
    [self.headerView removeObserver:self forKeyPath:@"mainTypeIndex"];
    [self.headerView removeObserver:self forKeyPath:@"secondaryTypeIndex"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    for(ETHMensaContentViewController *cvc in self.allContentViewControllers)
    {
        cvc.mainTypeIndex = self.headerView.mainTypeIndex;
    }
    self.settingsViewController.secondaryTypeIndex = self.headerView.secondaryTypeIndex;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{

    self.blurredBackground.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);

    self.mensenScrollView.delegate = nil;
    self.mensenScrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.mensenScrollView.delegate = self;

    NSInteger extra = [[NSUserDefaults standardUserDefaults] boolForKey:@"showGame"];

    self.mensenScrollView.contentSize = CGSizeMake(
        self.view.bounds.size.width * (self.selectedMensen.count + (float)extra + 1.0f), self.view.bounds.size.height);

    self.mensenScrollView.contentOffset = CGPointMake(
        self.mensenScrollView.frame.size.width * [[NSUserDefaults standardUserDefaults] floatForKey:@"selectedMensa"],
        0);

    CGFloat headerHeight =
        [self.headerView sizeThatFits:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)].height;
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, headerHeight);

    [self updateVisibleMensaViews];

    for(ETHMensaContentViewController *cvc in self.activeContentViewControllers)
    {
        cvc.view.frame = CGRectMake(self.mensenScrollView.frame.size.width * cvc.mensaIndex,
                                    CGRectGetMaxY(self.headerView.frame), self.mensenScrollView.frame.size.width,
                                    self.mensenScrollView.frame.size.height - CGRectGetMaxY(self.headerView.frame));
    }
}

/**
 *  Load the available mensa list from the user defaults or once a week from backend
 */
- (void)loadMensen
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastDate:mensa"];
    if(date && -[date timeIntervalSinceNow] < 7 * 24 * 60 * 60)
    {
        NSArray *result = [[NSUserDefaults standardUserDefaults] arrayForKey:@"lastResult:mensa"];
        NSMutableArray *mutableResult = [NSMutableArray array];
        for(NSDictionary *mensa in result)
        {
            NSMutableDictionary *mutableMensa = [mensa mutableCopy];
            mutableMensa[@"loadingDay"] = @(NO);
            mutableMensa[@"loadingWeek"] = @(NO);
            [mutableMensa removeObjectForKey:@"lunchMenus"];
            [mutableMensa removeObjectForKey:@"eveningMenus"];
            [mutableMensa removeObjectForKey:@"weekMenus"];
            [mutableMensa removeObjectForKey:@"dayLoadingError"];
            [mutableMensa removeObjectForKey:@"weekLoadingError"];
            [mutableResult addObject:mutableMensa];
        }
        self.allMensen = mutableResult;
        [self updateMensaFilter];
    }
    else
    {

        NSArray *result = [[NSUserDefaults standardUserDefaults] arrayForKey:@"lastResult:mensa"];
        NSMutableArray *mutableResult = [NSMutableArray array];
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                                           { [mutableResult addObject:[obj mutableCopy]]; }];
        self.allMensen = mutableResult;
        [self updateMensaFilter];

        [ETHBackend
            loadAction:@"mensen"
              complete:^(NSArray *result, NSError *error)
                       {

                  if(error)
                  {
                      [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Laden der Mensen fehlgeschlagen", nil)
                                                  message:error.localizedDescription
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Erneut versuchen", nil)
                                        otherButtonTitles:nil] show];
                  }
                  else
                  {

                      [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"lastResult:mensa"];
                      [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastDate:mensa"];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      self.allMensen = result;
                      [self updateMensaFilter];
                      [self loadMenus:nil];
                  }
              }];
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:@"didChangeMensaSelection"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
                                                             {
                                                      [self updateMensaFilter];
                                                      self.mensenScrollView.contentOffset =
                                                          CGPointMake(self.mensenScrollView.frame.size.width *
                                                                          (self.selectedMensen.count),
                                                                      0);
                                                      self.mensenScrollView.contentSize =
                                                          CGSizeMake(self.view.bounds.size.width *
                                                                         (self.selectedMensen.count + 1.0f),
                                                                     self.view.bounds.size.height);
                                                      [self updateVisibleMensaViews];
                                                  }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self loadMensen];
}

/**
 *  update view with filtered mensen
 */
- (void)updateMensaFilter
{

    self.selectedMensen = [self filterSelectedMensen:self.allMensen];

    self.blurredBackground.mensen = self.selectedMensen;
    self.headerView.mensen = self.selectedMensen;

    for(ETHMensaContentViewController *cvc in self.allContentViewControllers)
    {
        cvc.mensen = self.selectedMensen;
    }

    [self.view setNeedsLayout];
}

- (void)setSelectedMensen:(NSArray *)selectedMensen
{

    BOOL shouldLoad = _selectedMensen.count != selectedMensen.count;
    _selectedMensen = selectedMensen;

    if(shouldLoad) [self loadMenus:self];
}

- (void)loadMenus:(id)sender
{

    for(NSMutableDictionary *mensa in _selectedMensen)
    {
        if([mensa[@"loadingDay"] boolValue] == NO)
        {

            mensa[@"loadingDay"] = @YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ETHMensaDidUpdateMenus" object:mensa];

            [ETHBackend loadAction:@"menus"
                            params:@
                            {
                                @"mensa": mensa[@"id"]
                            }
                          complete:^(id result, NSError *error)
                                   {

                              if(error)
                              {
                                  mensa[@"dayLoadingError"] = error;
                              }
                              else
                              {
                                  mensa[@"lunchMenus"] = result[@"todayLunch"];
                                  mensa[@"eveningMenus"] = result[@"todayEvening"];
                              }

                              mensa[@"loadingDay"] = @NO;

                              [[NSNotificationCenter defaultCenter] postNotificationName:@"ETHMensaDidUpdateMenus"
                                                                                  object:mensa];
                          }];
        }
        if([mensa[@"loadingWeek"] boolValue] == NO)
        {

            mensa[@"loadingWeek"] = @YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ETHMensaDidUpdateMenus" object:mensa];

            [ETHBackend loadAction:@"weekmenus"
                            params:@
                            {
                                @"mensa": mensa[@"id"]
                            }
                          complete:^(id result, NSError *error)
                                   {
                              if(error)
                              {
                                  mensa[@"weekLoadingError"] = error;
                              }
                              else
                              {
                                  mensa[@"weekMenus"] = result;
                              }

                              mensa[@"loadingWeek"] = @NO;

                              [[NSNotificationCenter defaultCenter] postNotificationName:@"ETHMensaDidUpdateMenus"
                                                                                  object:mensa];
                          }];
        }
    }
}

/**
 *  Returns the user selected mensen or a default selection
 *
 *  @param allMensen
 *
 *  @return filtered mensa array
 */
- (NSArray *)filterSelectedMensen:(NSArray *)allMensen
{

    NSArray *filteredIds = [[NSUserDefaults standardUserDefaults] arrayForKey:@"filteredMensen"];
    if(!filteredIds)
    {
        filteredIds =
            @[@3, @13, @26, @16, @12, @6, @19, @9, @22, @25, @2, @15, @8, @21, @5, @24, @1, @27, @4, @20, @10, @23];
        [[NSUserDefaults standardUserDefaults] setObject:filteredIds forKey:@"filteredMensen"];
    }
    NSMutableArray *filteredMensen = [NSMutableArray array];
    NSMutableArray *allMensenIds = [NSMutableArray array];
    for(NSDictionary *mensa in allMensen)
    {
        BOOL filtered = [filteredIds containsObject:@([mensa[@"id"] intValue])];
        if(!filtered)
        {
            [filteredMensen addObject:mensa];
        }
        [allMensenIds addObject:@([mensa[@"id"] intValue])];
    }
    if(![allMensen isEqualToArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"allMensen"]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:allMensen forKey:@"allMensen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changedAllMensen" object:nil userInfo:nil];
    }

    return [filteredMensen copy];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateVisibleMensaViews];
}



/**
 *  Update scroll view contend and background depending on scroll view offset
 */
- (void)updateVisibleMensaViews
{

    CGFloat p = self.mensenScrollView.contentOffset.x / self.mensenScrollView.frame.size.width;
    [[NSUserDefaults standardUserDefaults] setInteger:round(p) forKey:@"selectedMensa"];

    self.blurredBackground.position = p;
    self.headerView.position = p;

    NSUInteger firstVisible = MAX(0, floor(p - 0.5));
    NSUInteger lastVisible = MIN(self.selectedMensen.count - 1, ceil(p + 0.5));
    for(ETHMensaContentViewController *cvc in self.activeContentViewControllers.copy)
    {
        if(cvc.mensaIndex < firstVisible || cvc.mensaIndex > lastVisible)
        {
            [cvc.view removeFromSuperview];
            [self.activeContentViewControllers removeObject:cvc];
            [self.queuedContentViewControllers addObject:cvc];
        };
    }

    for(NSInteger i = firstVisible; i <= lastVisible; i++)
    {
        BOOL hasCvc = NO;
        for(ETHMensaContentViewController *cvc in self.activeContentViewControllers)
        {
            if(cvc.mensaIndex == i)
            {
                hasCvc = YES;
            }
        }
        if(!hasCvc)
        {
            ETHMensaContentViewController *newCvc = [self dequeueContentViewController];
            [self.mensenScrollView addSubview:newCvc.view];
            newCvc.view.alpha = 0;
            [UIView animateWithDuration:0.5
                             animations:^
                                        { newCvc.view.alpha = 1; }];
            newCvc.mensaIndex = i;
            newCvc.view.frame =
                CGRectMake(self.mensenScrollView.frame.size.width * i, CGRectGetMaxY(self.headerView.frame),
                           self.mensenScrollView.frame.size.width,
                           self.mensenScrollView.frame.size.height - CGRectGetMaxY(self.headerView.frame));
            [self.activeContentViewControllers addObject:newCvc];
        }
    }

    self.settingsViewController.view.frame =
        CGRectMake(self.mensenScrollView.frame.size.width * self.selectedMensen.count,
                   CGRectGetMaxY(self.headerView.frame), self.mensenScrollView.frame.size.width,
                   self.mensenScrollView.frame.size.height - CGRectGetMaxY(self.headerView.frame));

    self.gameViewController.view.frame =
        CGRectMake(self.mensenScrollView.frame.size.width * (self.selectedMensen.count + 1.0f), 0,
                   self.mensenScrollView.frame.size.width, self.mensenScrollView.frame.size.height);

    self.settingsViewController.view.hidden = self.allMensen.count == 0;
    self.headerView.hidden = self.allMensen.count == 0;

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"showGame"])
    {
        self.headerView.alpha = ((float)self.selectedMensen.count - p + 1.0f);
    }
    else
    {
        self.headerView.alpha = 1;
    }
}

- (ETHMensaContentViewController *)dequeueContentViewController
{
    if(self.queuedContentViewControllers.count == 0)
    {
        ETHMensaContentViewController *cvc = [[ETHMensaContentViewController alloc] init];
        cvc.mensen = self.selectedMensen;
        cvc.mainTypeIndex = self.headerView.mainTypeIndex;
        [self.allContentViewControllers addObject:cvc];
        [self addChildViewController:cvc];
        return cvc;
    }
    else
    {
        ETHMensaContentViewController *cvc = self.queuedContentViewControllers.firstObject;
        [self.queuedContentViewControllers removeObjectAtIndex:0];
        return cvc;
    }
}

@end
