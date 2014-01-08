//
//  TRAddSourceViewController.m
//  TweetRide
//
//  Created by Jal Jalali Ekram on 12/16/2013.
//  Copyright (c) 2013 Jal Jalali Ekram. All rights reserved.
//

#import "TRAddSourceViewController.h"

@interface TRAddSourceViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneAdd;
@property (weak, nonatomic) IBOutlet UITextField *addSource;

@end

@implementation TRAddSourceViewController

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if (sender != self.doneAdd) {
        return;
    }
    
    if (self.addSource.text.length > 0) {
        self.fetchSource = [[TRTweetSource alloc] init];
        self.fetchSource.accountName = self.addSource.text;
        
    }
     
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
