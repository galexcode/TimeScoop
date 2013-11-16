//
//  HistoryCell.m


#import "HistoryCell.h"

@implementation HistoryCell

/**
 * Special getter for the class's reuseIdentifier
 * @return NSString string to return
 */
+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [UIView animateWithDuration:0.2 animations:^{
        if (editing) {
            [self.durationLabel setAlpha:0.0];
        }else{
            [self.durationLabel setAlpha:1.0];
        }
    }];
}

/**
 * Dealloc method to deallocate references and outlets.
 */
- (void)dealloc
{
    [self setEndDateLabel:nil];
    [self setNameLabel:nil];
    [self setDurationLabel:nil];
    [self setStartDateLabel:nil];
}

@end