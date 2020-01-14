//
//  SPermenantThread.m
//  PermenantThread-C
//
//  Created by Sun on 2020/1/14.
//  Copyright © 2020 sun. All rights reserved.
//

#import "SPermenantThread.h"

@interface SThread : NSThread
@end

@implementation SThread
- (void)dealloc {
    NSLog(@"SThread被销毁");
}
@end

@interface SPermenantThread()
@property (nonatomic, strong) SThread *innerThread;
@end

@implementation SPermenantThread

#pragma mark - public methods

- (instancetype)init {
    if (self = [super init]) {
        self.innerThread = [[SThread alloc] initWithBlock:^{
            NSLog(@"创建RunLoop");
            // 创建SourceContext
            // {0}初始化，防止垃圾数据干扰
            CFRunLoopSourceContext context = {0};
            // 创建source
            CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
            // 给RunLoop添加source，让RunLoop不会退出
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
            // 启动RunLoop
            // 第三个参数代表是否退出循环执行RunLoop
            // 如果设置为true。则需要自己写while循环启动RunLoop
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
            
            NSLog(@"RunLoop结束");
        }];
        [self.innerThread start];
    }
    return self;
}

// 外界使用这个方法来执行任务
- (void)executeTask:(SPermenantThreadTask)task {
    // 线程不存在或者任务是空的，直接结束
    if (!self.innerThread || !task) return;
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

// 给外界调用，用于销毁线程
- (void)stop {
    // 线程不存在直接结束
    if (!self.innerThread) return;
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

/**
 在SPermenantThread被销毁之前，先销毁线程
 SPermenantThread要被销毁了，所以对于 innerThread 的引用也没有了，按理说innerThread应该被销毁了
 但是因为RunLoop还在存活，所以线程并不会被销毁
 */
- (void)dealloc {
    NSLog(@"SPermenantThread销毁 - %s", __func__);
    [self stop];
}

#pragma mark - private methods

// 内部方法，销毁线程
- (void)__stop {
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)__executeTask:(SPermenantThreadTask)task {
    task();
}

@end
