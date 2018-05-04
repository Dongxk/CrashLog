//
//  ViewController.m
//  CrashLog
//
//  Created by 董向坤 on 16/11/15.
//  Copyright © 2016年 董向坤. All rights reserved.
//

#import "ViewController.h"

#import <MessageUI/MessageUI.h>
@interface ViewController ()<MFMessageComposeViewControllerDelegate>

@end

@implementation ViewController



/**
 一、Crash原因
 
 Crash原因有共性，归纳起来有：
 
1 内存管理错误
2 程序逻辑错误
3 SDK错误 （部署版本< 编译版本）
4 主线程阻塞
 
 1.内存管理错误
 
 内存管理是iPhone开发所要掌握的最基本问题，特别是使用引用计数手动管理内存的情况。内存管理错误包括：
 
    1 内存泄漏：未释放不会再使用对象。比如alloc忘记release,malloc忘记free。可用XcodeProduct菜单下的Analyze功能来解决该问题；
    2 引用出错：引用已经被释放的对象指针。很多“莫名其妙”的Crash都是由于窗体经历的生命周期所导致的    （viewDidUnload、viewDidLoad），在iOSSimulator里模拟内存警告就可以解决该问题；
    3 内存警告：App使用的内存超出设备的限制，iOS将强制挂起App，强制挂起iOS是不会记录Crashlog，Flurry也无法记录。内存泄漏、快速/大量的分配内存都可能导致内存警告，这时候应该尽可能的释放不需要的资源。通过Instruments->Allocations里的Heapshot功能能够找出哪些资源未被释放。
 
 WWDC 2012的Session242 - iOS App Performance_ Memory是专门讨论内存管理这个话题。
 
 2.程序逻辑错误
 
    数组越界、堆栈溢出、并发操作、逻辑错误。扎实的编码基础、严谨细致的工作习惯、清晰的思路可以避免这类错误；
 
 3.SDK错误
 
    这个错误出现的现象是有的设备运行正常，有的会Crash。原因是未找到框架、类、方法、属性。比如：用iOS5.0 SDK编译并运行在iOS4.0的设备上，5.0的Twitter框架在4.0的设备上找不到。这种问题常出现在用苹果新发布的Xcode编译原有的工程。
 
 未找到框架的解决办法是：部署版本>= 编译版本。iOS框架向后兼容做的很棒，部署版本> 编译版本一般不会出现问题。
 
 未找到类、方法、属性的解决办法是：先判断是否存在再使用
 
 if(NSClassFromString(@"MFMailComposeViewController"))
 
 respondsToSelector:
 
 4.主线程阻塞
 
    主线程阻塞超过10s，iOS将强制挂起App。把长时间的任务放到后台线程去执行，可使用NSThread,NSOperation, dispatch。WWDC2012的Session235 - iOS App Performance_ Responsiveness有详细的介绍。
 
 二、解决Crash
 
 思路是：定位Crash的程序代码，预测Crash原因，寻找解决方案，测试。
 
 有多种方式可以定位Crash的程序代码：
 
 1. Debug模式时，iOSSimulator断点测试定位Crash的堆栈；
 
 2. 真机连接iTunes查看Crashlog (Debug模式下)；
 
 3. 通过Flurry的错误记录查看；
 
 定位之后，就是重新思考程序上下文逻辑，并有理由的预测Crash出现的原因。预测的越多，理解的越深。
 
 寻找解决方案的方法有：
 
    浏览苹果官方SDK文档，找出错误原因；
 
    Google搜索Crash输出的信息，重点查找行业内技术论坛：cocoachina、stackoverflow、iphonedevsdk等；
 
    查看历届WWDC的视频、示例代码；
 
    在工程里添加环境变量: NSZombieEnabled、NSDebugEnabled，输出有价值的信息；
 
    如果未找到任何信息，可以寻求苹果官方论坛、业内技术论坛的帮助；
 
 测试
 
 找到解决方案后就需要测试，测试功能输入输出的准确性、程序性能、是否引入新的bug。测试有专业的测试工程师来负责，但开发工程师不能依赖测试工程师来发现问题，尽量独立解决已知存在的问题。
 
 由于Xcode部署工程到真机上比较耗时间，如果可以的话尽可能用iOSSimulator来测试，以减少测试的时间。
 
 建议开发工程师有一个checklist，在产品测试时自己逐一过一下上面常见的问题，这个能够避免大部分Crash。下图是我们一个产品的FlurryError记录，那120个错误Session是测试Crash时留下的。当然这个记录是没有包括iOS将强制挂起App的情况。
 
 
 首先我们经常会闪退的异常有哪些呢？crash的产生来源于两种问题：违反iOS策略被干掉，以及自身的代码bug。
 
 1.IOS策略
 
 1.1 低内存闪退
 
 前面提到大多数crash日志都包含着执行线程的栈调用信息，但是低内存闪退日志除外，这里就先看看低内存闪退日志是什么样的。
 我们使用Xcode 5和iOS 7的设备模拟一次低内存闪退，然后通过Organizer查看产生的crash日志，可以发现Process和Type都为Unknown：
 
 
 1.2 Watchdog超时
 Apple的iOS Developer Library网站上，QA1693文档中描述了Watchdog机制，包括生效场景和表现。如果我们的应用程序对一些特定的UI事件（比如启动、挂起、恢复、结束）响应不及时，Watchdog会把我们的应用程序干掉，并生成一份响应的crash报告。
 
 1.3 用户强制退出
 
 一看到“用户强制退出”，首先可能想到的双击Home键，然后关闭应用程序。不过这种场景是不会产生crash日志的，因为双击Home键后，所有的应用程序都处于后台状态，而iOS随时都有可能关闭后台进程，所以这种场景没有crash日志。
 
 另一种场景是用户同时按住电源键和Home键，让iPhone重启。这种场景会产生日志（仅验证过一次），但并不针对特定应用程序。
 
 这里指的“用户强制退出”场景，是稍微比较复杂点的操作：先按住电源键，直到出现“滑动关机”的界面时，再按住Home键，这时候当前应用程序会被终止掉，并且产生一份相应事件的crash日志。
 
 通常，用户应该是遇到应用程序卡死，并且影响到了iOS响应，才会进行这样的操作——不过感觉这操作好高级，所以这样的crash日志应该比较少见。
 
 2. 代码bug
 此外，比较常见的崩溃基本都源于代码bug，比如数组越界、插空、空引用、引用未定义方法、多线程安全性、访问野指针、发送未实现的selector等。
 
 
 1、在开发环境中，应该将日志写入控制台；而在生产环境中，应该将日志写入文件。在调试代码的时候，不输出到控制台就无法在XCode中看到日志。当最好的方式是同时写入控制台和日志文件。
 2、应该分为多种不同的日志级别（错误、警告、信息、详细）。
 3、当某个日志级别被禁用时，相应日志函数的调用开销要非常小。
 4、向控制台或者文件写日志的时候，不可以阻塞调用者线程。
 5、要定期删除日志文件以避免占满磁盘。
 6、日志函数的调用要非常方便，通常使用支持变参的C语法，不建议使用Object-C语法。NSLog的调用凡是非常简单，这一点就值得学习。

 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 30, 200, 60)];
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(sendEmailAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendEmailAction
{
    //以下例子就会出现闪退
    NSArray *arr = @[@"1", @"2"];
    NSLog(@"%@", arr[3]);
    
    
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:@"我是邮件主题"];
    // 设置收件人
    [mailCompose setToRecipients:@[@"xk_dlld2011@163.com"]];
    // 设置抄送人
    [mailCompose setCcRecipients:@[@"1043643016@qq.com"]];
    // 设置密抄送
    //    [mailCompose setBccRecipients:@[@"shana_happy@126.com"]];
    /**
     *  设置邮件的正文内容
     */
    NSString *emailContent = @"我是邮件内容";
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    //	[mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    /**
     *  添加附件
     */
    UIImage *image = [UIImage imageNamed:@"image"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"custom.png"];
    NSString *file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
    NSData *pdf = [NSData dataWithContentsOfFile:file];
    [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"cacheLog"];
    // 弹出邮件发送视图
    
    [self.navigationController presentViewController:mailCompose animated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    // 关闭邮件发送视图
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
