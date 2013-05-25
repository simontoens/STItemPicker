// @author Simon Toens 05/23/13

#import <Foundation/Foundation.h>

/**
 * Total control over all header elements in one convenient class.
 */
@interface ItemPickerHeader : NSObject

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, strong) NSString *boldLabel;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *smallerLabel;
@property(nonatomic, strong) NSString *smallestLabel;

/**
 * Set default values for unset labels.  Defaults to NO.
 */
@property(nonatomic, assign) BOOL defaultNilLabels;

@end