//
//  ViewController.m
//  AXCountingLabel
//
//  Created by devedbox on 16/8/16.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ViewController.h"
#import "AXCountingLabel/AXCountingLabel.h"
#import "AXCountingDownLabel.h"

@interface ViewController ()<AXCountingLabelDelegate>
/// Counting label.
@property(weak, nonatomic) IBOutlet AXCountingLabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    _label.gradientEnabled = NO;
}

- (IBAction)start:(id)sender {
//    NSDate *date = [NSDate dateWithTimeInterval:222397 sinceDate:[NSDate date]];
//    NSDate *date = [NSDate dateWithTimeInterval:10.0 sinceDate:[NSDate date]];
    NSDate *date = [NSDate dateWithTimeInterval:10*24*60*60 sinceDate:[NSDate date]];
    _label.threshold = 5.0;
    _label.delegate = self;
    
    [_label startCountingWithTime:[date timeIntervalSince1970] completion:^{
        if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"倒计时完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
#pragma clang diagnostic pop
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"倒计时完成" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:NULL];
        }
    }];
}

- (IBAction)stop:(id)sender {
    [_label stopCounting];
}

- (IBAction)pause:(id)sender {
    [_label pauseCounting];
}

- (IBAction)continueCounting:(id)sender {
    [_label continueCounting];
}

- (IBAction)restart:(id)sender {
    [_label restartCounting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - AXCountingLabelDelegate
- (void)countingLabelDidReachThreshold:(AXCountingLabel *)label {
    [label pauseCounting];
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"倒计时达到阈值" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
#pragma clang diagnostic pop
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"倒计时达到阈值，是否继续？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:NULL];
            label.threshold = -1;
            [label continueCounting];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
        [self presentViewController:alert animated:YES completion:NULL];
    }
}
@end
