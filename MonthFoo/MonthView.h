//
//  MonthView.h
//  MonthFoo
//
//  Created by Wayne Cochran on 4/3/14.
//  Copyright (c) 2014 WSUV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonthView;

typedef enum {
    MonthViewAnnotationNone = 0,
    MonthViewAnnotationCheckMark,
    MonthViewAnnotationX,
    MonthViewAnnotationStar,
    MonthViewAnnotationFlag,
} MonthViewAnnotationFlavor;

@protocol MonthViewDelegate <NSObject>
@optional
-(MonthViewAnnotationFlavor)annotationForDay:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y;
-(void)monthView:(MonthView*)monthView selectedDay:(int)d Month:(NSInteger)m Year:(NSInteger)y;
@end

@interface MonthView : UIView

@property (weak, nonatomic) id<MonthViewDelegate> monthViewDelegate;

@property (assign, nonatomic) NSInteger month; // jan = 1, .., dec = 12
@property (assign, nonatomic) NSInteger year;  // >= 1800 (Gregorian)

@end
