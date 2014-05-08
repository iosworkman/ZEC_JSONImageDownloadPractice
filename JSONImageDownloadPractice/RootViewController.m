//
//  RootViewController.m
//  JSONImageDownloadPractice
//
//  Created by Zec on 14-5-7.
//  Copyright (c) 2014年 Zec. All rights reserved.
//

#define IMAGEURL @"http://img3.douban.com/view/photo/raw/public/p2180078704.jpg"

#import "RootViewController.h"


@interface RootViewController ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
    NSString *str;
    NSURL *url;
    NSURLRequest *request;
    NSURLConnection *URLConnection;
    NSMutableData *dataSource;
    long long dataLength;
    UIImageView *imageView;
    UIImage *image;
    UIProgressView *progressView;
    UILabel *progressLabel;
    UIActivityIndicatorView *activityIndicatorView;
}

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    str = IMAGEURL;
    //  初始化NSURL对象
    url = [[NSURL alloc] initWithString:str];
    //  初始化NSURLRequest对象
    request = [[NSURLRequest alloc] initWithURL:url];
    //  启动请求
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    //  初始化缓存
    dataSource  =[[NSMutableData alloc] init];
    image =[UIImage imageNamed:@"photo"];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 20, self.view.frame.size.width,400);
    [self.view addSubview:imageView];
    
    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height + 30, 60, 40)];
    progressLabel.center = CGPointMake(self.view.frame.size.width/2, imageView.frame.origin.y + imageView.frame.size.height + 30);
    progressLabel.layer.borderWidth = 1;
    progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: progressLabel];
    
    progressView =[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(0, 0, 240, 40);
    progressView.center = CGPointMake(self.view.frame.size.width/2, progressLabel.frame.origin.y + progressLabel.frame.size.height + 50);
    [self.view addSubview:progressView];
    
    activityIndicatorView =[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicatorView.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    
    
}

#pragma mark - NSURLConnection代理
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"接收到响应");
    dataSource.length = 0;
    dataLength = [response expectedContentLength];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"正在接收数据");
    [dataSource appendData:data];
    CGFloat progressNumber =  (CGFloat)dataSource.length / dataLength;
//    NSLog(@"progressNumber = %.0f",progressNumber);
    progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progressNumber * 100];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [activityIndicatorView stopAnimating];
    NSLog(@"下载完成");
    imageView.image = [UIImage imageWithData:dataSource];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"接收数据失败");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
