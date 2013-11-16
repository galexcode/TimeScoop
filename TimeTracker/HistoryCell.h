//
//  HistoryCell.h

/**
 * Custom cell to display History objects' properties.
 */

#import <UIKit/UIKit.h>

@interface HistoryCell : UITableViewCell

/// display the name of the history item
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
/// display the duration of the history item
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
/// display the start date of the history item
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;
/// display the end date of the history item
@property (strong, nonatomic) IBOutlet UILabel *endDateLabel;

+ (NSString *)reuseIdentifier;

@end