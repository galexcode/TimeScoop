//
//  DataExportHelper.h
//  TimeTracker

/**
 * Class to export history objects from core data into .csv format.
 */

#import <Foundation/Foundation.h>

@interface DataExportHelper : NSObject

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

- (NSData*)exportAllHistoryItems:(NSArray*)items;

@end