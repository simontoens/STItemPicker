// @author Simon Toens 05/02/13

#import "ItemPickerSection.h"

@implementation ItemPickerSection


- (id)initWithTitle:(NSString *)title range:(NSRange)range
{
    if (self = [super init])
    {
        _title = title;
        _range = range;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"title: %@, range:{%i, %i}", _title, _range.location, _range.length];
}

@end
