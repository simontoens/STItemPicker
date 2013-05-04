// @author Simon Toens 05/02/13

#import <Foundation/Foundation.h>

/**
 * Similar to MPMediaQuerySection, with the same title and range properties.
 */
@interface ItemPickerSection : NSObject

- (id)initWithTitle:(NSString *)title range:(NSRange)range;

@property(nonatomic, strong, readonly) NSString *title;
@property(nonatomic, readonly) NSRange range;

@end