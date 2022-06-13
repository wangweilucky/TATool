//
//  TALoggerDetialController.m
//  ThinkingSDKDEMO
//
//  Created by wwango on 2022/6/13.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TALoggerDetialController.h"

@interface TALoggerDetialController ()
@property (strong, nonatomic) UITextView *textView;

@end

@implementation TALoggerDetialController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width,  UIScreen.mainScreen.bounds.size.height)];
    [self.view addSubview:self.textView];
    [self.textView setEditable:NO];
    self.textView.text = self.dic[@"message"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
