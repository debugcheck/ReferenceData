远程推送应用配置过程

1. 创建支持远程推送功能的App ID
2. 申请开发者证书，并选中刚刚创建的App ID
3. 下载CER文件，并导入钥匙串管理
4. 申请发布证书，并选中刚刚创建的App ID
5. 下载CER文件，并导入钥匙串管理
6. 检查App ID，确认证书已经指定

远程推送应用程序开发过程
1.	新建应用程序
2. 指定AppID，在developer.apple.com上设置的AppID

#ifdef __IPHONE_8_0
    // 注册接收通知的类型
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    
    // 注册允许接收远程推送通知
    [application registerForRemoteNotifications];
#else
    // 如果是iOS7.0，使用以下方法注册
    [application registerForRemoteNotificationTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound];
#endif


// 当得到苹果的APNs服务器返回的DeviceToken就会被调用
// 7040f7d5 5a974598 c5cf31b5 3e340b39 68affd25 122f0ce1 3f315226 396c2e5b
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"deviceToken是：%@", deviceToken);
}

// 接收到远程通知，触发方法和本地通知一致
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
}


*** 使用后台的远程消息推送

1>	在Capabilities中打开远程推送通知
2> 实现代理方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler

远程消息数据格式：
{"aps" : {"content-available" : 1},"content-id" : 42}

执行completionHandler有两个目的
1> 系统会估量App消耗的电量，并根据传递的UIBackgroundFetchResult 参数记录新数据是否可用
2> 调用完成的处理代码时，应用的界面缩略图会自动更新

注意：接收到远程通知到执行完网络请求之间的时间不能超过30秒

if (userInfo) {
    int contentId = [userInfo[@"content-id"] intValue];
    
    ViewController *vc = (ViewController *)application.keyWindow.rootViewController;
    [vc loadDataWithContentID:contentId completion:^(NSArray *dataList) {
        vc.dataList = dataList;
    
        NSLog(@"刷新数据结束");
        
        completionHandler(UIBackgroundFetchResultNewData);
    }];
} else {
    completionHandler(UIBackgroundFetchResultNoData);
}






