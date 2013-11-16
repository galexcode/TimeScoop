//
//  History.h
//  TimeTracker


/**
 * History core data model.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface History : NSManagedObject

/// duration of the activity
@property (nonatomic, retain) NSNumber * duration;
/// boolean value to determine whether a history object has been uploaded or not
@property (nonatomic, retain) NSNumber * uploaded;
/// name of history
@property (nonatomic, retain) NSString * name;
/// start date of history
@property (nonatomic, retain) NSDate * startDate;
/// end date of history
@property (nonatomic, retain) NSDate * endDate;
/// time when the activity was saved for later sorting
@property (nonatomic, retain) NSString *saveTime;

@end
