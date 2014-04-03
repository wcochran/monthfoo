//
//  MonthFooViewController.m
//  MonthFoo
//
//  Created by Wayne Cochran on 4/3/14.
//  Copyright (c) 2014 WSUV. All rights reserved.
//

#import "MonthFooViewController.h"

@interface MonthAnnotation : NSObject <NSCopying> // can be key in dictionary

@property (assign, nonatomic) NSInteger day;
@property (assign, nonatomic) NSInteger month;
@property (assign, nonatomic) NSInteger year;
@property (assign, nonatomic) MonthViewAnnotationFlavor flavor;

-(id)init;
-(id)copyWithZone:(NSZone *)zone;
-(id)initWithDay:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y;
-(BOOL)isEqualToMonthAnnotation:(MonthAnnotation*)other;
-(BOOL)isEqual:(id)other;
-(NSUInteger)hash;

@end

@implementation MonthAnnotation

-(id)init {
    return [self initWithDay:1 Month:1 Year:1970];
}

-(id)initWithDay:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y {
    if (self = [super init]) {
        _day = d;
        _month = m;
        _year = y;
        _flavor = MonthViewAnnotationNone;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    MonthAnnotation *clone = [[[self class] alloc] init];
    clone.day = _day;
    clone.month = _month;
    clone.year = _year;
    clone.flavor = _flavor;
    return clone;
}

-(BOOL)isEqualToMonthAnnotation:(MonthAnnotation*)other {
    return self.day == other.day && self.month == other.month && self.year == other.year;
}

-(BOOL)isEqual:(id)other {
    if (self == other)
        return YES;
    if (![other isKindOfClass:[MonthAnnotation class]])
        return NO;
    return [self isEqualToMonthAnnotation:other];
}

-(NSUInteger)hash {
    return (self.year - 1582)*12 + (self.month-1)*31 + (self.day-1);
}

@end

@interface MonthFooViewController () <UIAlertViewDelegate>
@end

@implementation MonthFooViewController {
    NSMutableDictionary *_annotations;
    MonthAnnotation *_selectedDay;
    MonthView *_selectedMonthView;
}

-(MonthViewAnnotationFlavor)annotationForDay:(NSInteger)d Month:(NSInteger)m Year:(NSInteger)y {
    if (_annotations == nil)
        return MonthViewAnnotationNone;
    MonthAnnotation *annotation = [[MonthAnnotation alloc] initWithDay:d Month:m Year:y];
    MonthAnnotation *monthAnnotation = [_annotations objectForKey:annotation];
    if (monthAnnotation)
        return monthAnnotation.flavor;
    return MonthViewAnnotationNone;
}

-(void)monthView:(MonthView *)monthView selectedDay:(int)d Month:(NSInteger)m Year:(NSInteger)y {
    MonthAnnotation *annotation = [[MonthAnnotation alloc] initWithDay:d Month:m Year:y];
    MonthAnnotation *monthAnnotation = [_annotations objectForKey:annotation];
    if (monthAnnotation == nil) {
        if (_annotations == nil)
            _annotations = [[NSMutableDictionary alloc] init];
        annotation.flavor = MonthViewAnnotationX;
        [_annotations setObject:annotation forKey:annotation];
        [monthView setNeedsDisplay];
    } else {
        _selectedDay = annotation;
        _selectedMonthView = monthView;
        NSString *msg = [NSString stringWithFormat:@"Do you really want to uncheck %d/%d/%d?", m, d, y];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Day" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Uncheck", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView:didDismissWithButtonIndex:%d", buttonIndex);
    if (buttonIndex == 1) {
        [_annotations removeObjectForKey:_selectedDay];
        [_selectedMonthView setNeedsDisplay];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.monthView.month = 3;
    self.monthView.year = 2014;
    self.monthView.monthViewDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
