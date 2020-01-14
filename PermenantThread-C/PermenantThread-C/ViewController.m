//
//  ViewController.m
//  PermenantThread-C
//
//  Created by Sun on 2020/1/14.
//  Copyright © 2020 sun. All rights reserved.
//

#import "ViewController.h"
#import "SPermenantThread.h"

@interface ViewController ()
@property (nonatomic, strong) SPermenantThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.thread = [[SPermenantThread alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.thread executeTask:^{
        NSLog(@"执行子线程任务");
    }];
}

- (IBAction)stopRunLoop:(id)sender {
    [self.thread stop];
}

- (void)dealloc {
    NSLog(@"控制器dealloc");
}

@end
