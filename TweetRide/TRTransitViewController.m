//
//  TRTransitViewController.m
//  TweetRide
//
//  Created by Jal Jalali Ekram on 12/23/2013.
//  Copyright (c) 2013 Jal Jalali Ekram. All rights reserved.
//

#import "TRTransitViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>


@interface TRTransitViewController ()


@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) NSMutableArray *allTweets;


@end

@implementation TRTransitViewController

- (IBAction)unwindToTransitTweets:(UIStoryboardSegue *)segue {
    // nothing to do 
}

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
    
    // calling the function that fetches tweets from the twitter account and parses them.
    [self fetchAndParseTweetTransit];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fetchAndParseTweetTransit {
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    
    // Asks for the Twitter accounts configured on the device.
    
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    
    //
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         // If we have access to the Twitter accounts configured on the device we will contact the Twitter API.
         
         // if a twiiter account is found on the device to connect with the api
         if (granted == YES){
             
             // retrieve the array of twitter accounts
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             
             // If there is a leat one account we will contact the Twitter API.
             
             if ([arrayOfAccounts count] > 0) {
                 
                 ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                 
                 // url to the address we are getting the data from
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 
                 // passing parameters to the api to get data from TTC_notices twitter account
                 NSDictionary *params = @{@"screen_name" : @"TTCnotices",
                                          @"include_rts" : @"0",
                                          @"count" : @"50"};
                 
                 
                 // this is where we are getting the data using SLRequest.
                 
                 SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                 
                 
                // adding the twitter account from
                 [posts setAccount:twitterAccount];
                 
                 // The postRequest: method call now accesses the NSData object returned.
                 [posts performRequestWithHandler:
                  
                  ^(NSData *response, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      // The NSJSONSerialization class is then used to parse the data returned and assign it to our array.
                      
                      self.tweets = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
                      
                      
                      //NSLog(_tweets);
                      
                      if (self.tweets.count != 0) {
                          
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTransit";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tweet = self.tweets[indexPath.row];

    NSString *tweetText = tweet[@"text"];
    
    if ([tweetText rangeOfString:@"clear" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        cell.imageView.image = [UIImage imageNamed:@"green-dot.png"];
        
    }
    
    else if ([tweetText rangeOfString:@"No Service" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        cell.imageView.image = [UIImage imageNamed:@"red-dot.png"];
   
    }
    
    else if ([tweetText rangeOfString:@"delay" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        cell.imageView.image = [UIImage imageNamed:@"yellow-dot.png"];
        
    }
    
    
    else if ([tweetText rangeOfString:@"suspend" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        cell.imageView.image = [UIImage imageNamed:@"yellow-dot.png"];
        
    }
    
    else if ([tweetText rangeOfString:@"divert" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        cell.imageView.image = [UIImage imageNamed:@"orange-dot.png"];
        
    }

    else if ([tweetText rangeOfString:@"hold" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        cell.imageView.image = [UIImage imageNamed:@"orange-dot.png"];
        
    }

    else {
        cell.imageView.image = [UIImage imageNamed:@"white-dot.png"];
    }
    
    // Configure the cell...
    
    cell.textLabel.text = tweet[@"text"];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.numberOfLines = 4;
    
    //No Selection Style
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    NSDate *apiTweetDate = [dateFormatter dateFromString:tweet[@"created_at"]];
    [dateFormatter setDateFormat:@"h:mm a 'on' eee MMM dd \"yy"];
    NSString *tweetDate = [dateFormatter stringFromDate:apiTweetDate];
    
    cell.detailTextLabel.text = tweetDate;
    
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



- (IBAction)refreshPressed:(id)sender {
    [self fetchAndParseTweetTransit];
}
@end
