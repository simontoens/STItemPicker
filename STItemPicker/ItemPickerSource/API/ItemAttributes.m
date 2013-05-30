// @author Simon Toens 05/27/13

#import "ItemAttributes.h"

@implementation ItemAttributes

@synthesize textColor = _textColor;
@synthesize userInteractionEnabled = _userInteractionEnabled;

- (id)init
{
    if (self = [super init])
    {
        _textColor = [UIColor blackColor];
        _userInteractionEnabled = YES;
    }
    return self;
}

@end