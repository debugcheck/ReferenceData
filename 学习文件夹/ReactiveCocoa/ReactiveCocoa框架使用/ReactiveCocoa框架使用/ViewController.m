//
//  ViewController.m
//  ReactiveCocoa框架使用
//
//  Created by lizhongqiang on 16/1/23.
//  Copyright © 2016年 lizhongqiang. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <RACSubscriber.h>
@interface ViewController ()

@end

@implementation ViewController

#pragma mark 总结：
/*
 RACSignal创建信号，自我理解：其实显示存储需要发送的信号，然后调用相应的方法subscribeNext来接受信号（在方法subscribeNext的内部会调用创建信号时候设置的block）
 RACSubject是先把subscribeNext后面的block存储到RACSubscriber对象里，其每次调用subscribeNext方法都会创建一个RACSubscriber信号订阅者对象，NSMutableArray *subscribers = RACSubject.subscribers;订阅者存到RACSubject对象的数组里，当有信号发出的时候，最终是通过RACCompoundDisposable对象去中转
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
#pragma mark ---- RACSignal发送信号与接收信号，顺序是：必须先接收信号（即订阅），再发送信号（因为实质上，都是RACSubscriber对象进行的操作）
    //1、创建信号-----从下面的实现步骤（先是生成信号，然后在对信号进行订阅）来看：信号类（RACSiganl）,默认是一个冷信号，也就是只有值发生改变时，才会触发，（换句话说：只有订阅了该信号，这个信号才会变成热信号，才会被触发）
    
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //block调用时刻：每当有订阅者订阅信号，就会调用block
        //2.发送信号
        [subscriber sendNext:@1];//RACSubscriber表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只有遵守这个协议，并且实现方法才能成为订阅者
        
        //如果不发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposableWithBlock:^{}]取消订阅信号
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            //block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block，取消订阅信号
            //执行完block后，当前信号就不在被订阅了。
            NSLog(@"信号被销毁");
        }];
    }];
    //信号创建时，传入的block，只有在订阅信号，即subscribeNext方法调用的时候，才会被调用
    //如果创建信号的时候，传入的block中有发送信号的方法sendNext:方法（RACSubscriber调用sendNext:方法的时候，会在其内部调用subscribeNext:传入的block（next）函数），就会调用其nextblock函数（也就是所谓的发送信号）
    //另外在sendNext:方法内部，也会去调用订阅信号传入的nextblock
    //3.订阅信号，才会激活信号。subscribeNext方法内部会根据传入的block创建RACSubscriber
    [siganl subscribeNext:^(id x) {
        //block调用时刻：每当有信号发出数据，就会调用block
        NSLog(@"接收到数据:%@",x);
    }];
    //总结，创建RACSignal的时候，仅仅只是把block存起来
    //RACSubscriber订阅激活信号后，先调用createSignal:传入的block，然后在调用subscribeNext:传入的next传入的block
    //需要注意的是：只要有sendNext发出，就会调用subscribeNext传入的block一次！，createSignal:传入的block只是相当于一个媒介，可有可无

#pragma mark -- RACSubject
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。经测试只有先订阅信号，后发送信号，才能有效
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    //1.创建信号(这个类的大致思路是：一个信号对象，存储着一个subscribers数组，然后每订阅一次信号，就会添加一个subscriber对象，然后每发送一次信号，就会遍历一次subscribers数组，然后对每个subscriber进行发送信号一次)
    RACSubject *subject = [RACSubject subject];
    //订阅信号
    [subject subscribeNext:^(id x) {
       //block调用时刻：当信号发出新值，就会调用
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        //block调用时刻：当信号发出新值，就会调用
        NSLog(@"第二个订阅者%@",x);
    }];
    
    //3.发送信号
    [subject sendNext:@"1"];
    
#pragma mark --- RACReplaySubject
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据--%@",x);
    }];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者接收到的数据--%@",x);
    }];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"发送消息" forState:UIControlStateNormal];
    btn.frame = CGRectMake(20, 100, 100, 30);
    btn.backgroundColor = [UIColor purpleColor];
    [btn sizeToFit];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(sendNotes) forControlEvents:UIControlEventTouchUpInside];
    
    
    MyRedView *redView = [[MyRedView alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    [self.view addSubview:redView];
    
    Method method = class_getInstanceMethod([MyRedView class], NSSelectorFromString(@"btnAction"));
    
    //rac_signalForSelector
    //创建一个信号，并通过runtime的方法消息机制来动态的创建一个类，并替换其forwardInvocation方法，在自定义的方法中利用该信号对象发送一个信号，被发送的消息对象为RACTuple:类
    //(值得注意的是这个函数返回的是一个 RACTuple。 这个 RACTuple 包含了 Selector 方法里面所有的参数。这样需要用到的时候主要按照顺序来获取。)
    //根据selector产生RACSubject(继承自RACSignal)信号,（也就是rac_signalForSelector后面的selector被执行的时候，调用！）
    //RACSubject:信号提供者，自己可以充当信号，又能发送信号。
    //使用场景:通常用来代替代理，有了它，就不必要定义代理了
    //点击事件发生的时候，默认会发送一条信息
    //
    [[redView rac_signalForSelector:method_getName(method)]subscribeNext:^(id x) {//@selector(btnAction)
        NSLog(@"点击红色按钮");
        CGPoint center = redView.center;
        center.x+=10;
        redView.center =center;
    }];
    //KVO
    //追根溯源：[strongTarget addObserver:RACKVOProxy.sharedProxy forKeyPath:self.keyPath options:options context:(__bridge void *)self];也是通过KVO实现的
    //只是中间会生成一个对象RACKVOProxy.sharedProxy去充当观察者，然后再去发送一个信号，
    //这个方法会返回一个RACSignal信号对象，再对该信号对象进行订阅
    /*
     RACSubscriber调用sendNext:方法的时候，会在其内部调用subscribeNext:传入的block（next）函数
     */
    [[redView rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld observer:nil]subscribeNext:^(id x) {
        
    }];
    [RACObserve(redView, center)subscribeNext:^(id center) {
        NSLog(@"%@", center);
    }];
}
- (void)click:(MyRedView *)redView{
    NSLog(@"%@--%s",[self class],__func__);
}
- (void)sendNotes{
    TwoViewController *twoVC = [[TwoViewController alloc]init];
    //设置代理信号
    twoVC.delegateSignal = [RACSubject subject];
    //订阅代理信号
    
    [twoVC.delegateSignal subscribeNext:^(id x) {
        NSLog(@"点击了通知按钮");
        //创建请求信号
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"发送请求");
            return nil;
        }];
        //订阅信号
        [signal subscribeNext:^(id x) {
            NSLog(@"接收数据1");
        }];
        //订阅信号
        [signal subscribeNext:^(id x) {
            NSLog(@"接收数据2");
        }];
        /*
         运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
         */
        
        //RACMulticastConnection:解决重复请求问题
        //1.创建信号
        RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"发送请求2");
            [subscriber sendNext:@1];
            return nil;
        }];
        //2.创建链接
        RACMulticastConnection *connection = [signal2 publish];
        
        //3.订阅信号
        //注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接，当调用连接，就会
        //一次性调用所有订阅者的sendNext:
        [connection.signal subscribeNext:^(id x) {
            NSLog(@"%@订阅者一信号",x);
        }];
        [connection.signal subscribeNext:^(id x) {
            NSLog(@"订阅者二信号");
        }];
        
        //4.连接，激活信号
        [connection connect];
        
    }];
#pragma mark ---- 1.代替代理
    
    
    [self presentViewController:twoVC animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
@implementation MyRedView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:self.btn];
        self.btn.backgroundColor = [UIColor redColor];
        [self.btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)btnAction{
    NSLog(@"%@--%s----%s",[self class],__func__,_cmd);
    //通过打印方法SEL即（_cmd）可知道（rac_alias_btnAction），这里的方法，已经在内部被修改了，虽然名字这里看到的没有变，但是仅仅是把方法的实现部分copy到另一个，也就是内部调用的方法中。
}

@end