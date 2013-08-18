// @author Simon Toens 05/27/13

#import <SenTestingKit/SenTestingKit.h>
#import "ItemAttributes.h"

@interface ItemAttributesTest : SenTestCase
@end

@implementation ItemAttributesTest

- (void)testItemAttributes
{
    
}

- (void)testImmutabilityOfDefaultAttributes
{
    ItemAttributes *attributes = [ItemAttributes getDefaultItemAttributes];
    
    STAssertEquals(attributes.userInteractionEnabled, YES, @"Bad value");
    
    @try 
    {
        attributes.textColor = nil;
        STAssertTrue(NO, @"Not ok");
    }
    @catch (NSException *exception) {
        STAssertTrue(YES, @"Ok");
    }
    
    @try 
    {
        attributes.descriptionTextColor = nil;
        STAssertTrue(NO, @"Not ok");
    }
    @catch (NSException *exception) {
        STAssertTrue(YES, @"Ok");
    }
    
    @try 
    {
        attributes.userInteractionEnabled = NO;
        STAssertTrue(NO, @"Not ok");
    }
    @catch (NSException *exception) {
        STAssertTrue(YES, @"Ok");
    }
}

@end