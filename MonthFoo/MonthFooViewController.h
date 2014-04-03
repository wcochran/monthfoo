//
//  MonthFooViewController.h
//  MonthFoo
//
//  Created by Wayne Cochran on 4/3/14.
//  Copyright (c) 2014 WSUV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthView.h"

@interface MonthFooViewController : UIViewController <MonthViewDelegate>

@property (weak, nonatomic) IBOutlet MonthView *monthView;

@end
