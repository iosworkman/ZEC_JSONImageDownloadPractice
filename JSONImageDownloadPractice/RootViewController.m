//
//  RootViewController.m
//  JSONImageDownloadPractice
//
//  Created by Zec on 14-5-7.
//  Copyright (c) 2014年 Zec. All rights reserved.
//

#define IMAGEURL @"http://img3.douban.com/view/photo/raw/public/p2180078704.jpg"

#import "RootViewController.h"
#import "FMDatabase.h"


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
    FMDatabase *database;
    BOOL _isInsertImageDataOK;
    BOOL _isCreatePhotoTableOK;
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

//将数据归档到本地

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    str = IMAGEURL;
    //  初始化NSURL对象
    url = [[NSURL alloc] initWithString:str];
    //  初始化NSURLRequest对象
    request = [[NSURLRequest alloc] initWithURL:url];
    //  启动请求
    
    database = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    
    
    
    if ([database open]) {
        NSLog(@"数据库打开成功");
        
    }
    else
    {
        NSLog(@"数据库打开失败");
    }
    
    if ([self getImageFromDatabase].count == 0) {
        
        [NSURLConnection connectionWithRequest:request delegate:self];
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
    else if (([self getImageFromDatabase].count != 0))
    {
        [self readImageData];
        NSLog(@"选择从数据库读取");
    }
}


- (NSString *)getDatabasePath
{
    //获取document路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];
    
    
    NSLog(@"%@",path);
    
    //返回数据库保存的路径，数据库文件名字后缀.db
    return [path stringByAppendingPathComponent:@"JSONImageDownloadPractice.db"];
}

- (NSMutableArray *)getImageFromDatabase
{
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    
    FMResultSet *results = [database executeQuery:@"select * from Xman"];
    
    //遍历
    while (results.next)
    {
        
        NSData *data = [results dataForColumn:@"photo"];
        
        [imageArray addObject:data];
    }
    
    return imageArray;
}


-(void)createPhotoTable
{


    _isCreatePhotoTableOK = [database executeUpdate:@"create table if not exists Xman (id integer primary key autoincrement,photo blob)"];

    _isInsertImageDataOK = [database executeUpdate:@"insert into Xman (photo) values (?)",dataSource];
    
    if (_isInsertImageDataOK) {
        NSLog(@"图片插入到数据库");
    }

//    _isInsertImageDataOK = YES;
    NSLog(@"ssssssssssssssssssss");
    [database close];

}

-(void)readImageData
{
    FMResultSet *sets = [database executeQuery:@"select * from Xman"];
    
    NSData *data = [sets dataForColumn:@"photo"];

    imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageWithData:data];
    imageView.frame = CGRectMake(0, 20, self.view.frame.size.width,400);
    [self.view addSubview:imageView];
    
    NSLog(@"照片是从数据库读出来的");

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
//    NSLog(@"正在接收数据");
    [dataSource appendData:data];
    CGFloat progressNumber =  (CGFloat)dataSource.length / dataLength;
//    NSLog(@"progressNumber = %.0f",progressNumber);
    progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progressNumber * 100];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [activityIndicatorView stopAnimating];
    NSLog(@"下载完成");
//    NSLog(@"database %@",dataSource);
    imageView.image = [UIImage imageWithData:dataSource];
    
    [self createPhotoTable];
    
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
