//
//  ViewController.m
//  test
//
//  Created by 孙建飞 on 16/4/18.
//  Copyright © 2016年 sjf. All rights reserved.
//

#import "ViewController.h"
#import "TestTableViewController.h"
#import "JYKeyBoardListener.h"
@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   self.extendedLayoutIncludesOpaqueBars = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImage *image = [UIImage imageNamed:@"navbar"];
    UIImage *newImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2-1,image.size.width/2-1,image.size.height/2,image.size.width/2)
                                              resizingMode:UIImageResizingModeTile];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setBackgroundImage:newImage forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)hideKeboard:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
}
- (IBAction)jump:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.navigationController pushViewController:[TestTableViewController new] animated:YES];
}

- (IBAction)present:(UIBarButtonItem *)sender {
    
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nav = [storyBoard instantiateViewControllerWithIdentifier:@"PRENAV"];

    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

@end
