//
//  MyAnnotationView.m
//  MapTest
//
//  Created by Nancy Fan on 2017/5/31.
//  Copyright © 2017年 Nancy Fan. All rights reserved.
//

#import "MyAnnotationView.h"

@implementation MyAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    NSLog(@"initWithAnnotation");
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"MyAnnotation");
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.centerOffset = CGPointMake(0, 0);
        //定义改标注总的大小
        self.frame = CGRectMake(0, 0, 14, 20);
        
        _bgImageView = [[UIImageView alloc] initWithFrame:self.frame];
        _bgImageView.image = [UIImage imageNamed:@"pin_point.png"];
        [self addSubview:_bgImageView];
        
        UIImageView *paoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 100)];
        [paoView setImage:[UIImage imageNamed:@"note_bg.png"]];
                
        NSArray *info = [annotation.title componentsSeparatedByString:@", "];
        NSString *location = info[0];
        NSString *date = info[1];
        NSString *aqiLevel = info[2];
        NSString *url = info[3];
        
    
        UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 65, 45)];
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [picView setImage:[UIImage imageWithData:data]];
        [picView setAlpha:0.5];
        [paoView addSubview:picView];
        
        
        UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 59, 120, 10)];
        [locationLabel setText:location];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setFont:[UIFont systemFontOfSize:6]];
        [locationLabel setTextColor:[UIColor lightGrayColor]];
        [locationLabel setTextAlignment:NSTextAlignmentLeft];
        [paoView addSubview:locationLabel];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 68, 120, 10)];
        [dateLabel setText:date];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
        [dateLabel setFont:[UIFont systemFontOfSize:6]];
        [dateLabel setTextColor:[UIColor lightGrayColor]];
        [dateLabel setTextAlignment:NSTextAlignmentLeft];
        [paoView addSubview:dateLabel];
        
        UIImageView *ratingView = [[UIImageView alloc] initWithFrame:CGRectMake(105, 12, 45, 55)];
        [ratingView setImage:[UIImage imageNamed:@"rating_bg.png"]];
        [paoView addSubview:ratingView];
        
        
        UILabel *aqiScoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(104.5, 34, 46, 28)];
        [aqiScoreLabel setText:aqiLevel];
        [aqiScoreLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [aqiScoreLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [aqiScoreLabel setNumberOfLines:0];
        [aqiScoreLabel setTextColor:[UIColor whiteColor]];
        [aqiScoreLabel setTextAlignment:NSTextAlignmentCenter];
        [paoView addSubview:aqiScoreLabel];
        
        NSLayoutConstraint *centerXRate = [NSLayoutConstraint constraintWithItem:aqiScoreLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:ratingView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        [paoView addConstraint:centerXRate];
        
        self.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:paoView];

    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
