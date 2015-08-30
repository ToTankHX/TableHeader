//
//  HeaderTable.m
//  TableHeader
//
//  Created by LL on 15/8/29.
//  Copyright (c) 2015年 LL. All rights reserved.
//

#import "HeaderTable.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

@interface HeaderTable ()

@property (nonatomic, strong) NSMutableArray *blurImages;
@property (nonatomic, assign) CGFloat   HeaderTableHeight;
@property (nonatomic, strong) UIView *scrollHeaderView;

@end
@implementation HeaderTable

- (HeaderTable*)initWithTableViewWithHeaderImage:(UIImage *)headerImage WithHeight:(CGFloat)height
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self = [[HeaderTable alloc] initWithFrame:bounds];
    
    //图片设定frame，由此可知这是双层覆盖
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height)];
    [self.headerImageView setImage:headerImage];
    [self addSubview:self.headerImageView];
    
    self.HeaderTableHeight = height;//获取表头高度
    
    self.tableView = [[UITableView alloc] initWithFrame:self.frame];
    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height)];
    [self addSubview:self.tableView];
    
    //开启监听机制
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    self.blurImages = [[NSMutableArray alloc] init];
    [self prepareForBlurImages];//设置毛玻璃,其实也是设置表头放大
    
    return self;
}


- (void)setHeaderImage:(UIImage *)headerImage
{
    [self.headerImageView setImage:headerImage];
    [self.blurImages removeAllObjects];
    [self prepareForBlurImages];
}

//设置毛玻璃效果
- (void)prepareForBlurImages
{
    CGFloat factor = 0.1f;
    [self.blurImages addObject:self.headerImageView.image];
    for (NSUInteger i =0; i < self.HeaderTableHeight/10; i ++) {
        //test
//        [self.blurImages addObject:self.headerImageView.image];
        
        [self.blurImages addObject:[self.headerImageView.image boxblurImageWithBlur:factor]];
        factor += 0.04;
    }
 
}

- (void)animationForTableView
{
    CGFloat offset = self.tableView.contentOffset.y;
    
    if (self.tableView.contentOffset.y > 0) {
        NSInteger index = offset / 10;
        if (index < 0) {
            index = 0;
        }
        else if (index >= self.blurImages.count){
            index = self.blurImages.count - 1;
        }
        
        UIImage *image = self.blurImages[index];
        if (self.headerImageView.image != image) {
            [self.headerImageView setImage:image];
        }
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    else{
        self.headerImageView.frame = CGRectMake(offset, 0, self.frame.size.width + (-offset)*2, self.HeaderTableHeight + (-offset));
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.tableView) {
        [self animationForTableView];
    }
}


- (void)removeFromSuperview
{
    if (self.tableView) {
        [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
    [super removeFromSuperview];
}

- (void)dealloc
{
    if (self.tableView) {
        [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
}
@end

@implementation UIImage (Blur)

- (UIImage *)boxblurImageWithBlur:(CGFloat)blur
{
    NSData *imageData = UIImageJPEGRepresentation(self, 1);
    UIImage *destImage = [UIImage imageWithData:imageData];
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if (pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
  
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld",error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld",error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld",error);
    }
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
    

    
}

@end
