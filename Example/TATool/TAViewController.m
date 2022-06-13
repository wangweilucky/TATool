//
//  TAViewController.m
//  TATool
//
//  Created by wwango on 06/13/2022.
//  Copyright (c) 2022 wwango. All rights reserved.
//

#import "TAViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import <TATool/TALoggerManager.h>

@interface TAViewController ()

@end

@implementation TAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
    [ThinkingAnalyticsSDK startWithAppId:@"asda" withUrl:@"www.bai.com"];
    [[ThinkingAnalyticsSDK sharedInstance] track:@"test"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
