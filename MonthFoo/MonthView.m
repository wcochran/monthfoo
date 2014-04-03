//
//  MonthView.m
//  MonthFoo
//
//  Created by Wayne Cochran on 4/3/14.
//  Copyright (c) 2014 WSUV. All rights reserved.
//

#import "MonthView.h"

//
// http://en.wikipedia.org/wiki/Determination_of_the_day_of_the_week
// Tomohiko Sakamoto
// Returns 0 => sunday, 1 => monday, ..., 6 => saturday
//
static int dow(int y, int m, int d)
{
    static int t[] = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};
    y -= m < 3;
    return (y + y/4 - y/100 + y/400 + t[m-1] + d) % 7;
}

static BOOL isLeapYear(int y) {
    return y % 400 == 0 || (y % 4 == 0 && y % 100 != 0);
}

static int numDaysInMonth(int y, int m) {
    static int days[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    int n = days[m];
    if (m == 2 && isLeapYear(y))
        n++;
    return n;
}

@interface MonthView ()
-(void)installTapGestureRecognizer;
@end


@implementation MonthView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self installTapGestureRecognizer];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self installTapGestureRecognizer];
    }
    return self;
}

#define MARGIN 2

-(CGRect)contentRect {
    const CGFloat size = MIN(self.bounds.size.width,self.bounds.size.height) - MARGIN;
    const CGRect contentRect = CGRectMake((self.bounds.size.width - size)/2,
                                          (self.bounds.size.height - size)/2,
                                          size, size);
    return contentRect;
}

-(void)handleTap:(UITapGestureRecognizer*)tapGestureRecognizer {
    if (![self.monthViewDelegate respondsToSelector:@selector(monthView:selectedDay:Month:Year:)])
        return;
    
    const CGPoint tapPoint = [tapGestureRecognizer locationInView:self];
    const CGRect contentRect = [self contentRect];
    const CGSize gridSquareSize = CGSizeMake(contentRect.size.width/7, contentRect.size.height/7);
    const int row = floor((tapPoint.y - contentRect.origin.y)/gridSquareSize.height);
    const int col = floor((tapPoint.x - contentRect.origin.x)/gridSquareSize.width);
    
    if (row <= 0 || row > 6 || col < 0 || col > 6)
        return;
    
    NSInteger startDayOfWeek = dow(self.year, self.month, 1);
    NSInteger daysInMonth = numDaysInMonth(self.year, self.month);

    const int N = 7*(row-1) + col - startDayOfWeek;
    if (N < 0 || N >= daysInMonth)
        return;
    
    [self.monthViewDelegate monthView:self selectedDay:N+1 Month:self.month Year:self.year];
}

-(void)installTapGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //
    // Find largest square in center of view.
    //
    const CGRect contentRect = [self contentRect];
    const CGFloat size = contentRect.size.width;
    
    //
    // We draw onto a 700x700 canvas and set the Current Transform Matrix (CTM)
    // to scale this to 'contentRect.'
    //
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, contentRect.origin.x, contentRect.origin.y);
    CGContextScaleCTM(context, size/700, size/700);
    
    //
    // Draw Month/Year title.
    //
    NSDictionary *monthYearAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:40],
                                           NSForegroundColorAttributeName: [UIColor blackColor]};
    static NSString *monthStrings[] = {@"",
        @"January", @"February", @"March", @"April", @"May", @"June",
        @"July", @"August", @"September", @"October", @"November", @"December"
    };
    NSString *monthYearString = [NSString stringWithFormat:@"%@ %d", monthStrings[self.month], self.year];
    const CGSize headTextSize = [monthYearString sizeWithAttributes:monthYearAttributes];
    const CGRect headRect = CGRectMake((700 - headTextSize.width)/2, (50 - headTextSize.height)/2,
                                       headTextSize.width, headTextSize.height);
    [monthYearString drawInRect:headRect withAttributes:monthYearAttributes];
    
    //
    // Draw days of week.
    //
    NSDictionary *dowAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:28],
                                     NSForegroundColorAttributeName: [UIColor blackColor]};
    NSArray *dowStrings = @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"];
    CGContextSetLineWidth(context, 3);
    for (int c = 0; c < 7; c++) {
        CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 1);
        CGContextFillRect(context, CGRectMake(c*100, 50, 100, 50));
        CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 1.0);
        CGContextStrokeRect(context, CGRectMake(c*100, 50, 100, 50));
        NSString *dow = [dowStrings objectAtIndex:c];
        const CGSize dowSize = [dow sizeWithAttributes:dowAttributes];
        const CGRect dowRect = CGRectMake(c*100 + (100 - dowSize.width)/2, 50 + (50 - dowSize.height)/2,
                                          dowSize.width, dowSize.height);
        [dow drawInRect:dowRect withAttributes:dowAttributes];
    }
    
    
    //
    // Draw Month grid lines.
    //
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextSetLineWidth(context, 3);
    CGContextMoveToPoint(context, 0, 50);
    CGContextAddLineToPoint(context, 700, 50);
    CGContextSetLineCap(context, kCGLineCapSquare);
    for (int r = 1; r < 8; r++) {
        CGContextMoveToPoint(context, 0, r*100);
        CGContextAddLineToPoint(context, 700, r*100);
        CGContextStrokePath(context);
    }
    for (int c = 0; c < 8; c++) {
        CGContextMoveToPoint(context, c*100, 50);
        CGContextAddLineToPoint(context, c*100, 700);
        CGContextStrokePath(context);
    }
    
    //
    // Draw days of month.
    //
    NSInteger startDayOfWeek = dow(self.year, self.month, 1);
    NSInteger daysInMonth = numDaysInMonth(self.year, self.month);
    
    NSDictionary *numberAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:26],
                                        NSForegroundColorAttributeName: [UIColor blackColor]};
    NSDictionary *annotationAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:70],
                                            NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    CGContextSetLineWidth(context, 4);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    int r = 1;
    int c = startDayOfWeek;
    for (int d = 1; d <= daysInMonth; d++) {
        const CGRect monthRect = CGRectMake(c*100, r*100, 100, 100);
        NSString *dayStr = [NSString stringWithFormat:@"%d", d];
        const CGSize dsize = [dayStr sizeWithAttributes:numberAttributes];
        const CGRect drect = CGRectMake(monthRect.origin.x + (42 - dsize.width)/2,
                                        monthRect.origin.y + (42 - dsize.height)/2,
                                        dsize.width, dsize.height);
        [dayStr drawInRect:drect withAttributes:numberAttributes];
        
        if ([self.monthViewDelegate respondsToSelector:@selector(annotationForDay:Month:Year:)]) {
            MonthViewAnnotationFlavor flavor = [self.monthViewDelegate annotationForDay:d Month:self.month Year:self.year];
            if (flavor != MonthViewAnnotationNone) {
                NSString *annotationStr = @"";
                if (flavor == MonthViewAnnotationCheckMark)
                    annotationStr = @"✔︎";
                else if (flavor == MonthViewAnnotationX)
                    annotationStr  = @"✘";
                else if (flavor == MonthViewAnnotationStar)
                    annotationStr = @"☆";
                else if (flavor == MonthViewAnnotationFlag)
                    annotationStr = @"⚐";
                const CGSize asize = [annotationStr sizeWithAttributes:annotationAttributes];
                const CGRect arect = CGRectMake(monthRect.origin.x + (100 - asize.width)/2,
                                                monthRect.origin.y + (100 - asize.height)/2,
                                                asize.width, asize.height);
                [annotationStr drawInRect:arect withAttributes:annotationAttributes];
            }
        
        }
        
        if (c == 6) {
            c = 0;
            r++;
        } else {
            c++;
        }
    }
    
    CGContextRestoreGState(context);
}


@end
