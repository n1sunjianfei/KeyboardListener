//
//  PreViewController.m
//  test
//
//  Created by JianF.Sun on 17/9/27.
//  Copyright © 2017年 sjf. All rights reserved.
//

#import "PreViewController.h"
#import "JYKeyBoardListener.h"
@interface PreViewController ()

@end

@implementation PreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    [JYKeyBoardListener unUsedIn:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismiss:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)hidekeyBoard:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
}

-(void)dealloc{
    NSLog(@"dealloc");
}


@end
