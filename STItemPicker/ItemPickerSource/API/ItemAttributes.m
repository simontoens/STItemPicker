// @author Simon Toens 05/27/13

#import "ItemAttributes.h"
#import "Preconditions.h"

@interface ImmutableItemAttributes : ItemAttributes
@end

@implementation ItemAttributes

@synthesize descriptionTextColor = _descriptionTextColor;
@synthesize textColor = _textColor;
@synthesize userInteractionEnabled = _userInteractionEnabled;

static ItemAttributes *kDefaultAttributes;

+ (void)initialize
{
    kDefaultAttributes = [[ImmutableItemAttributes alloc] init];
}

+ (ItemAttributes *)getDefaultItemAttributes
{
    return kDefaultAttributes;
}

- (id)init
{
    if (self = [super init])
    {
        _textColor = [UIColor blackColor];
        _descriptionTextColor = [UIColor grayColor];
        _userInteractionEnabled = YES;
    }
    return self;
}

@end

@implementation ImmutableItemAttributes

- (void)setTextColor:(UIColor *)textColor
{
    [Preconditions assert:NO message:@"Cannot modify this instance"];
}

- (void)setDescriptionTextColor:(UIColor *)descriptionColor
{
    [Preconditions assert:NO message:@"Cannot modify this instance"];    
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [Preconditions assert:NO message:@"Cannot modify this instance"];        
}

@end