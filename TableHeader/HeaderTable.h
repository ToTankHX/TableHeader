//
//  HeaderTable.h
//  TableHeader
//
//  Created by LL on 15/8/29.
//  Copyright (c) 2015年 LL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderTable : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContentView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UITableView   *tableView;

/**
 * @biref 传入表头高度和表头图片
 */
- (HeaderTable*)initWithTableViewWithHeaderImage:(UIImage*)headerImage WithHeight:(CGFloat)height;

- (void)setHeaderImage:(UIImage *)headerImage;

@end

@interface UIImage (Blur)
/**
 * @biref 添加毛玻璃效果
 */
- (UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end