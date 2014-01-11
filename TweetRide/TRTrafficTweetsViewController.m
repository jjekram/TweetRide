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
@property NSMutableArray *gardiner;
@property NSMutableArray *HW403;
@property NSMutableArray *HW410;
@property NSMutableArray *HWDVP;
@property NSMutableArray *HW427;
@property NSMutableArray *HWQEW;
@property NSMutableArray *HW400;
@property NSMutableArray *HW404;
@property NSMutableArray *HW407;
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
    self.allHighways = @[@"401",@"Gardiner", @"403",@"410",@"Don Valley Parkway",@"427",@"QEW",@"400",@"404",@"407", @"Other Highways"];
    self.HW401 = [[NSMutableArray alloc] init];
    self.gardiner = [[NSMutableArray alloc] init];
    self.HW403 = [[NSMutableArray alloc] init];
    self.HW410 = [[NSMutableArray alloc] init];
    self.HWDVP = [[NSMutableArray alloc] init];
    self.HW427 = [[NSMutableArray alloc] init];
    self.HWQEW = [[NSMutableArray alloc] init];
    self.HW404 = [[NSMutableArray alloc] init];
    self.HW407 = [[NSMutableArray alloc] init];
    self.HW400 = [[NSMutableArray alloc] init];
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
                      
                      
                      //Now we need to organize the tweets by highway (if there is at least 1 tweet)
                      
                      if (self.tweets.count != 0) {
                          
                          // going through each tweet to put them into appropiate array.
                          // ex. if there is a strig pattern "401", then add that tweet to HW401 array
                          
                          for (int i = 0; i < [self.tweets count]; i++) {
                              
                              
                              BOOL other = TRUE;    // this boolean is used to identify tweet that cannot be mapped to may array. FALSE when mapped to a highway.
                              
                              // mapping tweets to highways
                              
                              // 401
                              if ([self.tweets[i][@"text"] rangeOfString:@"401" ].location != NSNotFound) {
                                  
                                  // the index of the tweet in the _tweets array is added to the array instead of the tweet itself.
                                  [self.HW401 addObject:[NSNumber numberWithInt:i]];
                                  
                                  other = FALSE;
                              }
                              
                              // Gardiner
                              if ([self.tweets[i][@"text"] rangeOfString:@"gardiner" options:NSCaseInsensitiveSearch].location != NSNotFound){
                                  
                                  [self.gardiner addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              // 403
                              if ([self.tweets[i][@"text"] rangeOfString:@"403" ].location != NSNotFound){
                                  
                                  [self.HW403 addObject:[NSNumber numberWithInt:i]];
                                  
                                  other = FALSE;
                              }
                              
                              
                              // 410
                              if ([self.tweets[i][@"text"] rangeOfString:@"410" ].location != NSNotFound){
                                  
                                  [self.HW410 addObject:[NSNumber numberWithInt:i]];
                                  
                                  other = FALSE;
                              }
                              
                              // DVP
                              if ([self.tweets[i][@"text"] rangeOfString:@"DVP" options:NSCaseInsensitiveSearch].location != NSNotFound){
                                  
                                  [self.HWDVP addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              // 427
                              if ([self.tweets[i][@"text"] rangeOfString:@"427" ].location != NSNotFound){
                                  [self.HW427 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              // QEW
                              if ([self.tweets[i][@"text"] rangeOfString:@"qew" options:NSCaseInsensitiveSearch].location != NSNotFound){
                                  [self.HWQEW addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              // 400
                              if ([self.tweets[i][@"text"] rangeOfString:@"400" ].location != NSNotFound){
                                  [self.HW400 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              // 404
                              if ([self.tweets[i][@"text"] rangeOfString:@"404" ].location != NSNotFound){
                                  [self.HW404 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              // 407
                              if ([self.tweets[i][@"text"] rangeOfString:@"407" ].location != NSNotFound){
                                  [self.HW407 addObject:[NSNumber numberWithInt:i]];
                                  other = FALSE;
                              }
                              
                              


                              
                              // if not mapped to a highway then the tweet will appear in the other section
                              if (other) {
                    
                                  [self.otherHW addObject:[NSNumber numberWithInt:i]];
                              }
                              
                        }
                          
                          // Identifying the highways that have no tweets.
                          
                          // add -1 to the highway array if there is no tweets available (aka empty array)
                          
                          // 401
                          if (self.HW401.count == 0) {
                              
                              // adding -1 to the array.
                              [self.HW401 addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          // Gardiner
                          if (self.gardiner.count == 0) {
                              
                              [self.gardiner addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          //403
                          if (self.HW403.count == 0) {
                              
                              [self.HW403 addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          
                          // 410
                          if (self.HW410.count == 0) {
                              
                              [self.HW410 addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          // DVP
                          if (self.HWDVP.count == 0) {
                              
                              [self.HWDVP addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          // 427
                          if (self.HW427.count == 0) {
                              
                              [self.HW427 addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          // QEW
                          if (self.HWQEW.count == 0) {
                              
                              [self.HWQEW addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          // 400
                          if (self.HW400.count == 0) {
                              
                              [self.HW400 addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          // 404
                          if (self.HW404.count == 0) {
                              
                              [self.HW404 addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          // 407
                          if (self.HW407.count == 0) {
                              
                              [self.HW407 addObject:[NSNumber numberWithInt:-1]];
                              
                          }
                          
                          // Other
                          if (self.otherHW.count == 0) {
                              
                              [self.otherHW addObject:[NSNumber numberWithInt:-1]];
                          }
                          
                          
                          
                          // adding all the highway data into 'organizedTweets' array
                          
                          // 401
                          [self.organizedTweets addObject:self.HW401];
                          
                          // Gardiner
                          [self.organizedTweets addObject:self.gardiner];
                          
                          // 403
                          [self.organizedTweets addObject:self.HW403];
                          
                          // 410
                          [self.organizedTweets addObject:self.HW410];
                          
                          // DVP
                          [self.organizedTweets addObject:self.HWDVP];
                          
                          // 427
                          [self.organizedTweets addObject:self.HW427];
                          
                          // QEW
                          [self.organizedTweets addObject:self.HWQEW];
                          
                          // 400
                          [self.organizedTweets addObject:self.HW400];
                          
                          // 404
                          [self.organizedTweets addObject:self.HW404];
                          
                          // 407
                          [self.organizedTweets addObject:self.HW407];
                          
                          // Other
                          [self.organizedTweets addObject:self.otherHW];
                          
                        
                          dispatch_async(dispatch_get_main_queue(), ^{
                              
                              // reload the table with the data we just received now
                              [self.tableView reloadData];
                              
                              // also jump to the top of the table (section 0, row 0) after reloading.
                              
                              // indexPath to the top of the table.
                              NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
                              
                              // calling the scrolling function to execute the scroll
                             [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
                              
                          });
                          
                      }
                      
                  }];
                 
             }
             
         } else {
             
             // Handle failure to get account access
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle:@"Connection Error"
                                              message:@"Could Not connect to Twitter. Make sure you have a Twitter account added to this device."
                                              delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                 // show alert message
                 [alert show];
             });
             
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

    NSInteger numSec = 0;
    
    if (self.organizedTweets.count != 0) {
        numSec = [self.allHighways count];
    }
    // Return the number of sections.
    return numSec;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    
    // return 0 if no tweets found else return the number of tweets in each section.
    
    NSInteger numRows = 0;
    
    if (self.organizedTweets.count!= 0) {
        
        numRows = [self.organizedTweets[section] count];
        
    }
    
    
    return numRows;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    return self.allHighways[section]; //allHighways = @[@"401",@"403",@"410",@"Don Valley Parkway",@"427",@"QEW",@"Other Highways"]
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    // Configuring the cell
    
    //  casting the index from type number to type integer
    NSInteger tweetIndex = [self.organizedTweets[indexPath.section][indexPath.row] integerValue];
    
    // tweetindex -1 indicated that the section has no tweets. In that case, print
    
    // if the section is not empty we print the tweets in that section
    if (tweetIndex != -1) {
        NSDictionary *tweet = self.tweets[tweetIndex];
        
        NSString *tweetText = tweet[@"text"];
        
        // search for string in tweetText to identify the highway condition the tweet is representing
        
        // clear
        if ([tweetText rangeOfString:@"clear" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            // green dot appears in the cell
            cell.imageView.image = [UIImage imageNamed:@"green-dot.png"];
            
        }
        
        // open
        else if ([tweetText rangeOfString:@"open" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            // green dot appears
            cell.imageView.image = [UIImage imageNamed:@"green-dot.png"];
            
        }
        
        // block
        else if ([tweetText rangeOfString:@"block" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            // red dot appears
            cell.imageView.image = [UIImage imageNamed:@"red-dot.png"];
            
        }
        
        // closed
        else if ([tweetText rangeOfString:@"closed" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
            // red dot appears
            cell.imageView.image = [UIImage imageNamed:@"red-dot.png"];
            
        }
        
        // (collosion OR delay OR slow OR crash OR construction) AND none of the prev condition is true
        else if (([tweetText rangeOfString:@"collision" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"delay" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"slow" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"crash" options:NSCaseInsensitiveSearch].location != NSNotFound || [tweetText rangeOfString:@"construction" options:NSCaseInsensitiveSearch].location != NSNotFound) && [tweetText rangeOfString:@"closed" options:NSCaseInsensitiveSearch].location == NSNotFound && [tweetText rangeOfString:@"block" options:NSCaseInsensitiveSearch].location == NSNotFound && [tweetText rangeOfString:@"clear" options:NSCaseInsensitiveSearch].location == NSNotFound && [tweetText rangeOfString:@"open" options:NSCaseInsensitiveSearch].location == NSNotFound) {
            
            // yellow dot appears
            cell.imageView.image = [UIImage imageNamed:@"yellow-dot.png"];
            
        }
        
        // case where tweet does not indicate any significant condition of the highway.
        else{
            
            // nothing appears. a white dot is used for indentation purpose.
            cell.imageView.image = [UIImage imageNamed:@"white-dot.png"];
        }
        
        // printing the tweet
        cell.textLabel.text = tweet[@"text"];
        
        //  now we need to format the 'created_at' string to convert the time to a format we want to show it in
        
        // create dateFormatter object
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        // set the for as the format it appears in the tweet[@""]created_at
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        
        
        // get the created_at string from the array
        NSDate *apiTweetDate = [dateFormatter dateFromString:tweet[@"created_at"]];
        
        // set the format to the format you want it to have.
        [dateFormatter setDateFormat:@"h:mm a 'on' eee MMM dd \"yy"];
        
        // convert to type string from type date
        NSString *tweetDate = [dateFormatter stringFromDate:apiTweetDate];
        
        // print the date in the cell
        cell.detailTextLabel.text = tweetDate;
    }
    
    // case when there is no tweet
    else {
        
       // print the following message
       cell.textLabel.text = @"No recent tweets about this highway available at this moment.";
        
        // for indentation purpose only
       cell.imageView.image = [UIImage imageNamed:@"white-dot.png"];
        
        // subtitle should be blank
        cell.detailTextLabel.text = @"";
    
    }
    
    // make sure the cell hold the whole tweet. so let it adjust font to fit width
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    // setting the font
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    // min number of rows
    cell.textLabel.numberOfLines = 4;
    
    // nothing should happen when a cell is selected
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
