// @author Simon Toens 05/11/13

#import <SenTestingKit/SenTestingKit.h>
#import "ItemPickerContext.h"
#import "SampleCityDataSource.h"

@interface ItemPickerContextTest : SenTestCase
@end

@implementation ItemPickerContextTest

- (void)testEqualityAndHash
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerContext *ctx1 = [[ItemPickerContext alloc] initWithDataSource:ds];
    ctx1.selectedItem = @"item1";
    ctx1.selectedIndex = 10;
    
    ItemPickerContext *ctx2 = [[ItemPickerContext alloc] initWithDataSource:ds];
    ctx2.selectedItem = @"item1";
    ctx2.selectedIndex = 10;
    
    STAssertEqualObjects(ctx1, ctx2, @"bad equality");
    
    ItemPickerContext *ctx3 = [[ItemPickerContext alloc] initWithDataSource:ds];
    ctx3.selectedItem = @"item3";
    ctx3.selectedIndex = 13;

    NSArray *array = [NSArray arrayWithObjects:ctx1, ctx2, ctx3, nil];
    STAssertTrue([array containsObject:ctx1], @"Where's the ctx?");
    STAssertTrue([array containsObject:ctx2], @"Where's the ctx?");
    STAssertTrue([array containsObject:ctx3], @"Where's the ctx?");
    STAssertFalse([array containsObject:[[ItemPickerContext alloc] initWithDataSource:ds]], @"No way");
    
    STAssertEquals([ctx1 hash], [ctx2 hash], @"bad hash");
}

- (void)testCopy
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerContext *ctx = [[ItemPickerContext alloc] initWithDataSource:ds];
    ctx.selectedItem = @"a";
    ctx.selectedIndex = 4;
    ItemPickerContext *copy = [ctx copy];
    STAssertFalse(ctx == copy, @"Copy, what did you do?");
    STAssertEqualObjects(ctx, copy, @"Bad copy!");
}

@end