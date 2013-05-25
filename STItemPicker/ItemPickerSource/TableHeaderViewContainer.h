// @author Simon Toens 03/30/13

#import <Foundation/Foundation.h>

@interface TableHeaderViewContainer : NSObject

+ (TableHeaderViewContainer *)newTableHeaderViewWithImage:(UIImage *)image;

@property (nonatomic, weak) IBOutlet UILabel *boldLabel;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UILabel *smallerLabel;
@property (nonatomic, weak) IBOutlet UILabel *smallestLabel;

@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;

@end