//
//  TRTrafficTweetsViewController.m
//  TweetRide
//
//  Created by Jal Jalali Ekram on 12/13/2013.
//  Copyright (c) 2013 Jal Jalali Ekram. All rights reserved.
//

#import "TRTrafficTweetsViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>



@interface TRTrafficTweetsViewController ()

// data structure to hold the tweets from the twitter account
@property (strong, nonatomic) NSMutableArray *tweets;

// all the the tweets from the account but organized by highway
@property NSMutableArray *organizedTweets;


// list of all highways in this app. User later to generate sections in tableview.
@property NSArray *allHighways;

// following data structures hold tweets of the highways they are named after.
@property NSMutableArray *HW401;
@property NSMutableArray *HW403;
@property NSMutableArray *HW410;
@property NSMutableArray *HWDVP;
@property NSMutableArray *HW427;
@property NSMutableArray *HWQEW;
@property NSMutableArray *otherHW;

@end



@implementation TRTrafficTweetsViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initializing all the data structures.
    self.organizedTweets = [[NSMutableArray alloc] init];
    self.allHighways = @[@"401",@"403",@"410",@"Don Valley Parkway",@"427",@"QEW",@"Other Highways"];
    self.HW401 = [[NSMutableArray alloc] init];
    self.HW403 = [[NSMutableArray alloc] init];
    self.HW410 = [[NSMutableArray alloc] init];
    self.HWDVP = [[NSMutableArray alloc] init];
    self.HW427 = [[NSMutableArray alloc] init];
    self.HWQEW = [[NSMutableArray alloc] init];
    self.otherHW = [[NSMutableArray alloc] init];


    // calling 'fetchAndParseTweets' function to fetch and parse the tweets from the accounts' timeline.
    [self fetchAndParseTweets];
    
}


- (void)fetchAndParseTweets {
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    
    // Asks for the Twitter accounts configured on the device.
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         
         // If there is a account configured
         
         if (granted == YES){
             
             // Retrieves an array of Twitter accounts configured on the device.
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             
             
             // If there is at least one account we will be able to connect to the Twitter API.
             
             if ([arrayOfAccounts count] > 0) {
                 
                 // Sets the last account on the device to the twitterAccount variable.
                 ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                 
                 
                 // Requesting data from the api using the url below
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 
                 // parameters passed to the url
                 NSDictionary *params = @{@"screen_name" : @"680newstraffic",
                                          @"include_rts" : @"0",
                                          @"count" : @"50"};
                 
                 
                 // getting the data using SLRequest.
                 SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                 
                 // setting account as the twitter account found on the device
                 [posts setAccount:twitterAccount];
                 
                 // the postRequest: method call now accesses the NSData object returned.
                 [posts performRequestWithHandler:
                  
                  ^(NSData *response, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      
                      // the NSJSONSerialization class is then used to parse the data returned and assign it to tweets array.
                      self.tweets = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
                      
                      
                      
                      
                      if (self.tweets.count != 0) {
                          for (int i = 0; i < [self.tweets count]; i++) {
                              
                              BOOL other = TRUE;
                              if ([self.tweets[i][@"text"] rangeOfString:@"401" ].location != NSNotFound) {
                                  
                                  [self.HW401 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              if ([self.tweets[i][@"text"] rangeOfString:@"403" ].location != NSNotFound){
                                  
                                  [self.HW403 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              if ([self.tweets[i][@"text"] rangeOfString:@"410" ].location != NSNotFound){
                                  [self.HW410 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              if ([self.tweets[i][@"text"] rangeOfString:@"DVP" options:NSCaseInsensitiveSearch].location != NSNotFound){
                                  
                                  [self.HWDVP addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              if ([self.tweets[i][@"text"] rangeOfString:@"427" ].location != NSNotFound){
                                  [self.HW427 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              if ([self.tweets[i][@"text"] rangeOfString:@"qew" options:NSCaseInsensitiveSearch].location != NSNotFound){
                                  [self.HWQEW addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              if (other) {
                    
                                  [self.otherHW addObject:[NSNumber numberWithInt:i]];
                              }
                              
                        }
                          
                          //Identifying the highways that have no tweets.
                          
                          if (self.HW401.count == 0) {
                              [self.HW401 addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          if (self.HW403.count == 0) {
                              [self.HW403 addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          if (self.HW410.count == 0) {
                              [self.HW410 addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          if (self.HWDVP.count == 0) {
                              [self.HWDVP addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          if (self.HW427.count == 0) {
                              [self.HW427 addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          if (self.HWQEW.count == 0) {
                              [self.HWQEW addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          if (self.otherHW.count == 0) {
                              [self.otherHW addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          
                          
                          
                          [self.organizedTweets addObject:self.HW401];
                          [self.organizedTweets addObject:self.HW403];
                          [self.organizedTweets addObject:self.HW410];
                          [self.organizedTweets addObject:self.HWDVP];
                          [self.organizedTweets addObject:self.HW427];
                          [self.organizedTweets addObject:self.HWQEW];
                          [self.organizedTweets addObject:self.otherHW];
                          
                        
                          dispatch_async(dispatch_get_main_queue(), ^{
                              
                              [self.tableView reloadData]; // Here we tell the table view to reload the data it just recieved.
                              
                              NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
                               [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
                              
                          });
                          
                      }
                      
                  }];
                 
             }
             
         } else {
             
             // Handle failure to get account access
             NSLog(@"%@", [error localizedDescription]);
             
         }
         
     }];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [self.allHighways count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSInteger numRows = 0;
    if (self.organizedTweets.count!= 0) {
        numRows = [self.organizedTweets[section] count];
    }
    return numRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    return self.allHighways[section];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    // Configure the cell...
    NSInteger tweetIndex = [self.organizedTweets[indexPath.section][indexPath.row] integerValue];
    
    
    if (tweetIndex != -1) {
        NSDictionary *tweet = self.tweets[tweetIndex];
        
        NSString *tweetText = tweet[@"text"];
        
        if ([tweetText rangeOfString:@"clear" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell.imageView.image = [UIImage imageNamed:@"green-dot.png"];
            
        }
        
        else if ([tweetText rangeOfString:@"open" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell.imageView.image = [UIImage imageNamed:@"green-dot.png"];
            
        }
        
        else if ([tweetText rangeOfString:@"block" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell.imageView.image = [UIImage imageNamed:@"red-dot.png"];
            
        }
        
        else if ([tweetText rangeOfString:@"closed" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            cell.imageView.image = [UIImage imageNamed:@"red-dot.png"];
            
        }
        
        else if (([tweetText rangeOfString:@"collision" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"delay" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"slow" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"crash" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"construction" options:NSCaseInsensitiveSearch].location != NSNotFound) && [tweetText rangeOfString:@"closed" options:NSCaseInsensitiveSearch].location == NSNotFound && [tweetText rangeOfString:@"block" options:NSCaseInsensitiveSearch].location == NSNotFound && [tweetText rangeOfString:@"clear" options:NSCaseInsensitiveSearch].location == NSNotFound && [tweetText rangeOfString:@"open" options:NSCaseInsensitiveSearch].location == NSNotFound) {
            
            cell.imageView.image = [UIImage imageNamed:@"yellow-dot.png"];
            
        }
        
        else{
            
            cell.imageView.image = [UIImage imageNamed:@"white-dot.png"];
        }
        
        
        cell.textLabel.text = tweet[@"text"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        NSDate *apiTweetDate = [dateFormatter dateFromString:tweet[@"created_at"]];
        [dateFormatter setDateFormat:@"h:mm a 'on' eee MMM dd \"yy"];
        NSString *tweetDate = [dateFormatter stringFromDate:apiTweetDate];
        
        cell.detailTextLabel.text = tweetDate;
    }
    
    else {
        cell.textLabel.text = @"No recent tweets about this highway available at this moment.";
       cell.imageView.image = [UIImage imageNamed:@"white-dot.png"];
        cell.detailTextLabel.text = @"";
    
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.numberOfLines = 4;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}



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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


//This function is executed after refresh button is clicked.

- (IBAction)refreshPressed:(id)sender {
    
    //empty the all data structures
    [self.HW401 removeAllObjects];
    [self.HW403 removeAllObjects];
    [self.HW410 removeAllObjects];
    [self.HWDVP removeAllObjects];
    [self.HW427 removeAllObjects];
    [self.HWQEW removeAllObjects];
    [self.otherHW removeAllObjects];
    [self.organizedTweets removeAllObjects];
    
    [self fetchAndParseTweets];
    //[self.tableView setContentOffset:CGPointZero animated:YES];
}


@end
