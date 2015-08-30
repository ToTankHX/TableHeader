//
//  ViewController.m
//  TableHeader
//
//  Created by LL on 15/8/29.
//  Copyright (c) 2015年 LL. All rights reserved.
//

#import "ViewController.h"
#import "HeaderTable.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor colorWithWhite:0 alpha:0]] forBarMetrics:UIBarMetricsDefault];
    HeaderTable *table = [[HeaderTable alloc] initWithTableViewWithHeaderImage:[UIImage imageNamed:@"image"] WithHeight:200];
    table.tableView.dataSource = self;
    table.tableView.delegate = self;
    [self.view addSubview:table];
}

- (UIImage*)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *images = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return images;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"cell test %ld",indexPath.row + 1];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == -64) {
        [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
