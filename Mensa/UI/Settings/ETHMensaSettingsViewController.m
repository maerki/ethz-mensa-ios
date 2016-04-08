//
//  ETHMensaSettingsViewController.m
//  Mensa
//
//  Created by Nicolas Märki on 18.05.14.
//  Copyright (c) 2014 Nicolas Märki. All rights reserved.
//

#import "ETHMensaSettingsViewController.h"

#import "AFNetworking.h"

@interface ETHMensaSettingsViewController ()

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) NSMutableArray *filteredIds;
@property (nonatomic, strong) NSArray *allMensen;

@end

@implementation ETHMensaSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.tableView =
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                     style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = [UIView new];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.1];

    self.webView =
        [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.webView];
    self.webView.hidden = YES;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;

    [self.webView loadHTMLString:@"<html><body style='background-color:transparent;'</body></html>" baseURL:nil];
    
    [ETHBackend loadAction:@"about" complete:^(id result, NSError *error) {
        [self.webView loadHTMLString:result[@"html"] baseURL:[NSURL URLWithString:result[@"baseURL"]]];
    }];

    self.secondaryTypeIndex = 1;

    self.filteredIds = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"filteredMensen"] mutableCopy];
    self.allMensen = [[NSUserDefaults standardUserDefaults] arrayForKey:@"allMensen"];

    [[NSNotificationCenter defaultCenter]
        addObserverForName:@"changedAllMensen"
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *note)
                           {

                    self.filteredIds =
                        [[[NSUserDefaults standardUserDefaults] arrayForKey:@"filteredMensen"] mutableCopy];
                    self.allMensen = [[NSUserDefaults standardUserDefaults] arrayForKey:@"allMensen"];
                    [self.tableView reloadData];
                }];
}

- (void)setSecondaryTypeIndex:(NSUInteger)secondaryTypeIndex
{
    _secondaryTypeIndex = secondaryTypeIndex;

    switch(secondaryTypeIndex)
    {
        case 2:
        {
            self.tableView.hidden = YES;
            self.webView.hidden = NO;
        }
        break;

        default:
        {
            self.tableView.hidden = NO;
            self.webView.hidden = YES;
        }
        break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(section == 0)
//    {
//        return 1;
//    }
//    if(section == 1)
//    {
        return self.allMensen.count + 1;
//    }
//
//    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];

    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.01];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor whiteColor];

        UISwitch *sw = [UISwitch new];
        cell.accessoryView = sw;
        //        sw.onTintColor = [UIColor colorWithRed:0.014 green:0.260 blue:0.035 alpha:1.000];
        [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }

//    if(indexPath.section == 0)
//    {
//        cell.accessoryView.tag = -1;
//        cell.textLabel.text = NSLocalizedString(@"Show Salads and Soups", @"Salads and Soups Settings Title");
//    }
//    else
        if(indexPath.row == self.allMensen.count)
    {
        cell.accessoryView.tag = 666;
        cell.textLabel.text = nil;
        BOOL on = [[NSUserDefaults standardUserDefaults] boolForKey:@"showGame"];
        [(UISwitch *)cell.accessoryView setOn:on];
    }
    else
    {
        NSDictionary *mensa = self.allMensen[indexPath.row];
        cell.textLabel.text = mensa[@"name"];
        cell.accessoryView.tag = [mensa[@"id"] intValue];
        BOOL on = ![self.filteredIds containsObject:@([mensa[@"id"] intValue])];
        [(UISwitch *)cell.accessoryView setOn:on];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)switchChanged:(UISwitch *)sender
{
    if(sender.tag >= 0)
    {

        if(sender.tag == 666)
        {
            [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"showGame"];
        }
        else
        {
            if(sender.on)
            {
                [self.filteredIds removeObject:@(sender.tag)];
            }
            else if(![self.filteredIds containsObject:@(sender.tag)])
            {
                [self.filteredIds addObject:@(sender.tag)];
            }
        }

        [[NSUserDefaults standardUserDefaults] setObject:self.filteredIds forKey:@"filteredMensen"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeMensaSelection" object:nil userInfo:nil];
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch(section)
//    {
//        case 0:
//            return NSLocalizedString(@"General", @"General Settigns Title");
//            break;
//        case 1:
//            return NSLocalizedString(@"Selection", @"Selection Settigngs Title");
//            break;
//
//        default:
//            return nil;
//            break;
//    }
//}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view respondsToSelector:@selector(textLabel)])
    {
        [[(id)view textLabel] setTextColor:[UIColor whiteColor]];
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(self.secondaryTypeIndex == 1 && [ETHBackend loginName])
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"login"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    else if(self.secondaryTypeIndex == 1)
//    {
//    }
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath
*)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
