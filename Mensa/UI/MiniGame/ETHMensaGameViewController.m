//
//  ETHMensaGameViewController.m
//  Mensa
//
//  Created by Nicolas Märki on 10.06.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaGameViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ETHMensaGameViewController ()

@property (nonatomic, strong) NSMutableArray *blocks;
@property (nonatomic, strong) NSMutableArray *states;

@property (nonatomic) BOOL started;
@property (nonatomic) float probability;
@property (nonatomic, strong) NSMutableArray *ballsInRange;
@property (nonatomic) int score;

@property (nonatomic, strong) UILabel *scoreLabel, *scoreTitleLabel, *personalMaxLabel, *personalMaxTitleLabel,
    *globalMaxLabel, *globalMaxTitleLabel;

@property (nonatomic, strong) NSDate *stopDate, *lastScoreSync;

@end

@implementation ETHMensaGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self syncScores];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.clipsToBounds = YES;

    self.ballsInRange = [NSMutableArray array];

    self.blocks = [NSMutableArray array];
    for(int i = 0; i < 5; i++)
    {
        UIView *blockParent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        UIView *b = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        b.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
        [self.view addSubview:blockParent];
        [blockParent addSubview:b];
        [self.blocks addObject:b];
        b.tag = i;
        blockParent.tag = i;
        UITapGestureRecognizer *gr = [UITapGestureRecognizer new];
        [gr addTarget:self action:@selector(tapBlock:)];
        [blockParent addGestureRecognizer:gr];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 0.5f)];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        [b addSubview:line];
    }
    self.states = [@[@NO, @NO, @YES, @NO, @NO] mutableCopy];
    [self updateState];

    self.probability = 0.1;
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(spawnShape) userInfo:nil repeats:YES];

    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 50)];
    self.scoreLabel.font = [UIFont boldSystemFontOfSize:30];
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.scoreLabel];

    self.scoreTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 53, self.view.frame.size.width, 14)];
    self.scoreTitleLabel.text = NSLocalizedString(@"Score", nil);
    self.scoreTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreTitleLabel.textColor = [UIColor whiteColor];
    self.scoreTitleLabel.font = [UIFont systemFontOfSize:12];
    self.scoreTitleLabel.alpha = 0;
    [self.view addSubview:self.scoreTitleLabel];

    self.personalMaxLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width / 3.0f, 50)];
    self.personalMaxLabel.font = [UIFont boldSystemFontOfSize:20];
    self.personalMaxLabel.textColor = [UIColor whiteColor];
    self.personalMaxLabel.textAlignment = NSTextAlignmentCenter;
    self.personalMaxLabel.alpha = 0;
    [self.view addSubview:self.personalMaxLabel];

    self.personalMaxTitleLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(0, 49, self.view.frame.size.width / 3.0f, 14)];
    self.personalMaxTitleLabel.text = NSLocalizedString(@"Your Best", nil);
    self.personalMaxTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.personalMaxTitleLabel.textColor = [UIColor whiteColor];
    self.personalMaxTitleLabel.font = [UIFont systemFontOfSize:12];
    self.personalMaxTitleLabel.alpha = 0;
    [self.view addSubview:self.personalMaxTitleLabel];

    self.globalMaxLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(self.view.frame.size.width / 3.0f * 2.0f, 10, self.view.frame.size.width / 3.0f, 50)];
    self.globalMaxLabel.font = [UIFont boldSystemFontOfSize:20];
    self.globalMaxLabel.textColor = [UIColor whiteColor];
    self.globalMaxLabel.textAlignment = NSTextAlignmentCenter;
    self.globalMaxLabel.alpha = 0;
    [self.view addSubview:self.globalMaxLabel];

    self.globalMaxTitleLabel = [[UILabel alloc]
        initWithFrame:CGRectMake(self.view.frame.size.width / 3.0f * 2.0f, 49, self.view.frame.size.width / 3.0f, 14)];
    self.globalMaxTitleLabel.text = NSLocalizedString(@"Record", nil);
    self.globalMaxTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.globalMaxTitleLabel.textColor = [UIColor whiteColor];
    self.globalMaxTitleLabel.font = [UIFont systemFontOfSize:12];
    self.globalMaxTitleLabel.alpha = 0;
    [self.view addSubview:self.globalMaxTitleLabel];
}

- (void)syncScores
{
    
    [ETHBackend loadAction:@"syncScore"
                    params:@
                    {
                        @"score": @([[NSUserDefaults standardUserDefaults] integerForKey:@"gameGlobalMaxScore"])
                    }
                  complete:^(id result, NSError *error)
                           {

                      [[NSUserDefaults standardUserDefaults]
                          setInteger:MAX([[NSUserDefaults standardUserDefaults] integerForKey:@"gameGlobalMaxScore"],
                                         [result intValue])
                              forKey:@"gameGlobalMaxScore"];
                      [self setScore:_score];
                  }];
    self.lastScoreSync = [NSDate date];
}

- (void)setScore:(int)score
{
    _score = score;
    
    if (-self.lastScoreSync.timeIntervalSinceNow > 20.0f) {
        [self syncScores];
    }

    int maxscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"gameMaxScore"];
    int globalscore = [[NSUserDefaults standardUserDefaults] integerForKey:@"gameGlobalMaxScore"];
    if(score > maxscore)
    {
        maxscore = score;
        [[NSUserDefaults standardUserDefaults] setInteger:maxscore forKey:@"gameMaxScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if(score > globalscore)
    {
        globalscore = score;
        [[NSUserDefaults standardUserDefaults] setInteger:globalscore forKey:@"gameGlobalMaxScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    self.personalMaxLabel.text = @(maxscore).description;
    self.globalMaxLabel.text = @(globalscore).description;

    [UIView animateWithDuration:0.1
        animations:^
                   {
            self.scoreLabel.transform = CGAffineTransformMakeScale(1.4, 1.4);
            self.scoreTitleLabel.alpha = 1;
            self.personalMaxLabel.alpha = 0.6;
            self.personalMaxTitleLabel.alpha = 0.6;
            self.globalMaxLabel.alpha = 0.6;
            self.globalMaxTitleLabel.alpha = 0.6;
        }
        completion:^(BOOL finished)
                   {
            self.scoreLabel.text = @(self.score).description;

            [UIView animateWithDuration:0.1
                             animations:^
                                        { self.scoreLabel.transform = CGAffineTransformIdentity; }];
        }];
}

- (void)tapBlock:(UITapGestureRecognizer *)sender
{

    if(self.stopDate && -self.stopDate.timeIntervalSinceNow < 3.0f)
    {
        return;
    }

    if(!self.started)
    {
        self.started = YES;
        self.score = 0;
        self.scoreLabel.alpha = 1;
    }

    int index = sender.view.tag;
    if(![self.states[index] boolValue])
    {
        return;
    }
    for(int i = MAX(0, index - 1); i < MIN(5, index + 2); i++)
    {
        self.states[i] = @(![self.states[i] boolValue]);
    }
    if(![self.states containsObject:@YES])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                                                                                                    {
            self.states[2] = @YES;
            [UIView animateWithDuration:0.3
                                  delay:0
                 usingSpringWithDamping:0.4
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionBeginFromCurrentState |
                                        UIViewAnimationOptionAllowUserInteraction
                             animations:^
                                        { [self updateState]; }
                             completion:nil];
        });
    }
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^
                                { [self updateState]; }
                     completion:nil];
}

- (void)updateState
{
    float w = self.view.bounds.size.width / 5.0f;
    for(int i = 0; i < 5; i++)
    {
        UIView *b = self.blocks[i];
        b.transform = CGAffineTransformIdentity;
        b.superview.frame = CGRectMake(i * w, self.view.frame.size.height - 140.0f, w, w + 80.0f);
        b.frame = CGRectInset(CGRectMake(0, 40.0f, w, w), 10, 10);
        if([self.states[i] boolValue])
        {
            b.alpha = 1.0f;

            for(UILabel *ball in self.ballsInRange)
            {
                if(ball.tag == i)
                {
                    [UIView animateWithDuration:0.5
                        delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                        animations:^
                                   {
                            [self.blocks[i] setBackgroundColor:[ball.textColor colorWithAlphaComponent:0.5]];
                            ball.alpha = 0.0;
                        }
                        completion:^(BOOL finished)
                                   {
                            [UIView animateWithDuration:0.5
                                delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState |
                                        UIViewAnimationOptionAllowUserInteraction
                                animations:^
                                           {
                                    [self.blocks[i] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.15]];
                                }
                                completion:^(BOOL finished) {}];
                        }];
                    if([ball.text isEqualToString:@"-"])
                    {
                        [ball.layer removeAllAnimations];
                        //                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
            }
        }
        else
        {
            b.alpha = 0.0f;
            b.transform = CGAffineTransformMakeScale(0.01, 0.01);
        }
    }
}

- (void)spawnShape
{

    self.probability += 0.01;

    if(self.stopDate && -self.stopDate.timeIntervalSinceNow > 3.0f)
    {
        self.stopDate = nil;

        self.states = [@[@NO, @NO, @YES, @NO, @NO] mutableCopy];
        [self updateState];

        [UIView animateWithDuration:0.1
            animations:^
                       {
                self.scoreLabel.alpha = 0;
                self.scoreTitleLabel.alpha = 0;
                self.personalMaxLabel.alpha = 0;
                self.personalMaxTitleLabel.alpha = 00;
                self.globalMaxLabel.alpha = 0;
                self.globalMaxTitleLabel.alpha = 0;
            }
            completion:^(BOOL finished)
                       {
                self.scoreLabel.text = @(self.score).description;

                [UIView animateWithDuration:0.1
                                 animations:^
                                            { self.scoreLabel.transform = CGAffineTransformIdentity; }];
            }];
    }

    if(!self.started || (float)rand() / (float)RAND_MAX > self.probability)
    {
        return;
    }

    float w = self.view.bounds.size.width / 5.0f;
    float v = 30.0f;
    float row = rand() % 5;

    BOOL evil = NO;
    UIColor *color = [UIColor colorWithRed:0.118 green:0.918 blue:0.111 alpha:1.000];
    if((float)rand() / (float)RAND_MAX > 0.5)
    {
        evil = YES;
        color = [UIColor colorWithRed:0.751 green:0.058 blue:0.172 alpha:1.000];
    }

    UILabel *ball = [[UILabel alloc] initWithFrame:CGRectMake(row * w + w / 2.0f - v / 2.0f, -v, v, v)];
    ball.layer.cornerRadius = v / 2.0f;
    ball.layer.borderColor = [UIColor whiteColor].CGColor;
    ball.layer.borderWidth = 0.5f;
    ball.textColor = [UIColor whiteColor];
    ball.backgroundColor = [color colorWithAlphaComponent:0.5];
    ball.layer.shadowColor = [UIColor blackColor].CGColor;
    ball.layer.shadowRadius = 1.0f;
    ball.layer.shadowOpacity = 0.5;
    ball.clipsToBounds = YES;
    if(evil)
    {
        ball.text = @"-";
    }
    else
    {
        ball.text = @"+";
    }
    ball.font = [UIFont boldSystemFontOfSize:17];
    ball.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:ball];
    ball.tag = row;

    float dist = (self.view.frame.size.height - 100.0f - v / 2.0f + 10.0f) + v;
    float speed = 150.0f;

    [UIView animateWithDuration:dist / speed
        delay:0.0f
        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
        animations:^
                   {
            ball.center = CGPointMake(ball.center.x, self.view.frame.size.height - 100.0f - v / 2.0f + 10.0f);
        }
        completion:^(BOOL finished)
                   {

            if([self.states[(int)row] boolValue])
            {

                [UIView animateWithDuration:0.5
                    delay:0.0
                    options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                    animations:^
                               {
                        [self.blocks[(int)row] setBackgroundColor:[color colorWithAlphaComponent:0.5]];
                        ball.alpha = 0.0;
                    }
                    completion:^(BOOL finished)
                               {
                        [UIView animateWithDuration:0.5
                            delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState |
                                    UIViewAnimationOptionAllowUserInteraction
                            animations:^
                                       {
                                [self.blocks[(int)row] setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.15]];
                            }
                            completion:^(BOOL finished) {}];
                    }];

                if(evil)
                {
                    self.started = NO;
                    self.stopDate = [NSDate date];
                    //                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    self.probability = 0.1;
                }
                else if(self.started)
                {
                    [UIView animateWithDuration:(2.0f * v + w - 20.0f) / speed
                        delay:0.0f
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                        animations:^
                                   {
                            ball.center = CGPointMake(ball.center.x,
                                                      self.view.frame.size.height - 100.0f - v / 2.0f - 10.0f + w + v);
                        }
                        completion:^(BOOL finished) {}];
                    self.score = self.score + 1;
                }
            }
            else
            {

                [self.ballsInRange addObject:ball];

                [UIView animateWithDuration:(v + w - 20.0f) / speed
                    delay:0.0f
                    options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                    animations:^
                               {
                        ball.center =
                            CGPointMake(ball.center.x, self.view.frame.size.height - 100.0f - v / 2.0f - 10.0f + w + v);
                    }
                    completion:^(BOOL finished)
                               {

                        [self.ballsInRange removeObject:ball];

                        float dist2 = (self.view.frame.size.height + v / 2.0f) -
                                      (self.view.frame.size.height - 100.0f - v / 2.0f - 10.0f + w + v);
                        [UIView animateWithDuration:dist2 / speed
                            delay:0.0f
                            options:UIViewAnimationOptionCurveLinear
                            animations:^
                                       {
                                ball.center = CGPointMake(ball.center.x, self.view.frame.size.height + v / 2.0f);
                            }
                            completion:^(BOOL finished) {}];
                    }];
            }
        }];
}

- (void)viewDidLayoutSubviews
{

    [self updateState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
