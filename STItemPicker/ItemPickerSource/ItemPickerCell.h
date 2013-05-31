// @author Simon Toens 04/20/13

#import <Foundation/Foundation.h>

@interface ItemPickerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIImageView *iview;

@property (nonatomic, weak) IBOutlet UILabel *description;

@end