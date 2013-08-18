// @author Simon Toens 05/27/13

#import <Foundation/Foundation.h>

/**
 * Advanced item configuration.
 */
@interface ItemAttributes : NSObject

@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIColor *descriptionTextColor;
@property(nonatomic, assign) BOOL userInteractionEnabled;

+ (ItemAttributes *)getDefaultItemAttributes;

@end