// @author Simon Toens 05/27/13

#import <XCTest/XCTest.h>
#import "ItemAttributes.h"

@interface ItemAttributesTest : XCTestCase
@end

@implementation ItemAttributesTest

- (void)testItemAttributes
{
    
}

- (void)testImmutabilityOfDefaultAttributes
{
    ItemAttributes *attributes = [ItemAttributes getDefaultItemAttributes];
    
    XCTAssertEqual(attributes.userInteractionEnabled, YES, @"Bad value");
    
    @try 
    {
        attributes.textColor = nil;
        XCTAssertTrue(NO, @"Not ok");
    }
    @catch (NSException *exception) {
        XCTAssertTrue(YES, @"Ok");
    }
    
    @try 
    {
        attributes.descriptionTextColor = nil;
        XCTAssertTrue(NO, @"Not ok");
    }
    @catch (NSException *exception) {
        XCTAssertTrue(YES, @"Ok");
    }
    
    @try 
    {
        attributes.userInteractionEnabled = NO;
        XCTAssertTrue(NO, @"Not ok");
    }
    @catch (NSException *exception) {
        XCTAssertTrue(YES, @"Ok");
    }
}

@end