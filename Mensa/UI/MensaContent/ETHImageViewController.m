//
//  ETHImageViewController.m
//  Mensa
//
//  Created by Nicolas Märki on 30.08.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHImageViewController.h"

@interface ETHImageViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *menu;

@end

@implementation ETHImageViewController

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
    // Do any additional setup after loading the view.

    UIToolbar *bar =
        [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    bar.barStyle = UIBarStyleBlack;
    bar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:bar];

    bar.alpha = 0;
    [UIView animateWithDuration:0.5
                     animations:^
                                { bar.alpha = 1; }];

    self.tableView =
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                     style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    [self.view addSubview:self.tableView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(5, 40, 100, 30);
    [button setTitle:NSLocalizedString(@"Schliessen", nil) forState:UIControlStateNormal];
    button.tintColor = [UIColor colorWithWhite:1 alpha:1];
    [self.tableView.tableHeaderView addSubview:button];
    
    [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)openImage:(NSMutableDictionary *)menu index:(NSInteger)tag
{
    _menu = menu;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_menu[@"images"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *newimgv = [[UIImageView alloc] init];
        newimgv.clipsToBounds = YES;
        
        newimgv.layer.borderColor = [UIColor whiteColor].CGColor;
        newimgv.layer.borderWidth = 1.0f;
        newimgv.tag = 1;
        newimgv.frame = CGRectMake(10, 10, cell.frame.size.width-20, cell.frame.size.height-20);
        newimgv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [cell addSubview:newimgv];
    }
    
    UIImageView *imgv = (UIImageView *)[cell viewWithTag:1];
    
    
    NSMutableDictionary *imgObject = _menu[@"images"][indexPath.row];
    
    if([imgObject[@"loading"] boolValue])
    {
        imgv.image = nil;
    }
    else if(!imgObject[@"largeImg"])
    {
        int imgId = [imgObject[@"id"] intValue];
        imgObject[@"loading"] = @YES;
        
        NSString *thumbUrl =
        [NSString stringWithFormat:@"BACKEND_API_PATH", imgId];
        
        [ETHBackend loadImage:thumbUrl
                     complete:^(UIImage *image, NSError *error)
         {
             imgObject[@"loading"] = @NO;
             imgObject[@"largeImg"] = image;
             
             [self.tableView reloadData];
             
         }];
        [imgv setImage:imgObject[@"thumb"]];
    }
    else
    {
        [imgv setImage:imgObject[@"largeImg"]];
    }
    

    
   

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *imgObject = _menu[@"images"][indexPath.row];
    
    if(imgObject[@"thumb"])
    {
        return [imgObject[@"thumb"] size].height / [imgObject[@"thumb"] size].width * (tableView.bounds.size.width-20);
    }
    else if(imgObject[@"largeImg"])
    {
        return [imgObject[@"largeImg"] size].height / [imgObject[@"largeImg"] size].width * (tableView.bounds.size.width-20);
    }
    else
    {
        return 20;
    }

    
    
}

- (void)close:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
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
