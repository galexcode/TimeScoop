//
//  Activity.h
//  TimeTracker

/**
 * Activity core data model.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Activity : NSManagedObject

/// name of activity
@property (nonatomic, retain) NSString * name;
/// start date of activity
@property (nonatomic, retain) NSDate * startDate;
/// end date of activity
@property (nonatomic, retain) NSDate * endDate;

@end
