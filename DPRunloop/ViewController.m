//
//  ViewController.m
//  DPRunloop
//
//  Created by roc on 2018/7/11.
//  Copyright © 2018年 roc. All rights reserved.
//

#import "ViewController.h"

static NSString *IDENTIFIER = @"roc";
static CGFloat CELL_HEIGHT = 90.0f;

typedef void(^runloopBlock)(void);


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *DPTableView;

@property(nonatomic,strong)NSMutableArray *tasks;

@end

@implementation ViewController

+(void)addImage1WithCell:(UITableViewCell *)cell{
    
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 80, 80)];
    imageV.tag = 1;
    NSString *path1 = [[NSBundle mainBundle]pathForResource:@"IMG_2455" ofType:@"jpg"];
    UIImage *imag = [UIImage imageWithContentsOfFile:path1];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.image = imag;
    [UIView transitionWithView:cell.contentView duration:0.3 options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAutoreverse) animations:^{
        [cell.contentView addSubview:imageV];
    } completion:nil];
    
}

-(void)timeMethod{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   // [NSTimer scheduledTimerWithTimeInterval:0.00001 target:self selector:@selector(timeMethod) userInfo:nil repeats:YES];
    
    
    _tasks = [NSMutableArray array];
    
    _DPTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _DPTableView.delegate = self;
    _DPTableView.dataSource = self;
    [self.view addSubview:_DPTableView];
    [_DPTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:IDENTIFIER];
    
    [self addRunloopObserver];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return CELL_HEIGHT;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 200;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER forIndexPath:indexPath];
    
    //如果不移除，内存会暴增
    [[cell.contentView viewWithTag:1]removeFromSuperview];
    
    [self addTask:^{
        [ViewController addImage1WithCell:cell];
        NSLog(@"222");

    }];
    return cell;
}

-(void)addTask:(runloopBlock)task{
    [self.tasks addObject:task];
    
    if (self.tasks.count>7) {
        [self.tasks removeObjectAtIndex:0];
    }
}

//下面是关键的实现部分
-(void)addRunloopObserver{
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)(self),
        &CFRetain,
        &CFRelease,
        NULL
    };
    
    static CFRunLoopObserverRef runloopObserver;
    runloopObserver = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting, YES, 0, &callBack, &context);
    CFRunLoopAddObserver(runloop, runloopObserver, kCFRunLoopCommonModes);
}

static void callBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    ViewController *vc =(__bridge ViewController *)(info);
    
    if (vc.tasks.count == 0) {
        return;
    }

    runloopBlock task = vc.tasks.firstObject;
    task();
    [vc.tasks removeObjectAtIndex:0];
}

@end
