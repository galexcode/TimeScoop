//
//  DataExportHelper.m
//  TimeTracker


#import "DataExportHelper.h"
#import "History.h"
#import "Activity.h"

@implementation DataExportHelper

/**
 * Special getter for dateFormatter. Because it costs a lot to initalize a dateformatter for every cell.
 */
- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-dd";
    }
    return _dateFormatter;
}

/**
 * Special getter for timeFormatter. Because it costs a lot to initalize a dateformatter for every cell.
 */
- (NSDateFormatter*)timeFormatter
{
    if (_timeFormatter == nil) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = @"HH:mm:ss";
    }
    return _timeFormatter;
}

/**
 * Export all activities in a .csv format so you can import it easily into Microsoft Excel spreadsheet.
 * @param items items to export
 * @return NSData data of objects to return to be displayed in the .csv file when sending via email.
 */
- (NSData*)exportAllHistoryItems:(NSArray*)items
{
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc] init];
    NSString *columNames = @"Start date,Start time,End date,End time,Activity,Duration";
    NSString *colums = [columNames stringByAppendingString:@"\n"];
    [arrayToReturn addObject:colums];
    for(int i = 0; i < [items count]; ++i)
    {
        History *hist = (History *)[items objectAtIndex:i];
        [arrayToReturn addObject:[self createStringToSend:hist]];
    }
    return [[arrayToReturn componentsJoinedByString:@""] dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 * Special getter for dateFormatter. Because it costs a lot to initalize a dateformatter for every cell.
 * @param hist history object to convert to string.
 * @return NSString return a string that would be the row of the spreadsheet.
 */
- (NSString*)createStringToSend:(History*)hist
{
    NSString *startDateString = [self.dateFormatter stringFromDate:hist.startDate];
    NSString *startTimeString = [self.timeFormatter stringFromDate:hist.startDate];
    NSString *endDateString = [self.dateFormatter stringFromDate:hist.endDate];
    NSString *endTimeString = [self.timeFormatter stringFromDate:hist.endDate];

    int duration = [hist.duration intValue];
    int seconds = duration % 60;
    int minutes = (duration / 60) % 60;
    int hours = (duration / 3600);
    NSString *historyDuration = [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
    NSString *row = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@", startDateString, startTimeString, endDateString,
                                                                        endTimeString, hist.name, historyDuration, @"\n"];
    return row;
}

/**
 * Dealloc method to clear allocations and references.
 */
- (void)dealloc
{
    [self setDateFormatter:nil];
    [self setTimeFormatter:nil];
}

@end