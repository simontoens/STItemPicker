// @author Simon Toens 04/21/13

#include <stdlib.h>
#import "MultiDictionary.h"
#import "SampleCityDataSource.h"

@interface SampleCityDataSource()
@property(nonatomic, assign) NSUInteger depth;
@property(nonatomic, assign, readwrite) BOOL isLeaf;
@property(nonatomic, strong) NSArray *(^itemsProducer)(void);
@end

@implementation SampleCityDataSource

static MultiDictionary* kContinentsToCountries;
static MultiDictionary* kCountriesToRegions;
static MultiDictionary* kRegionsToStates;
static MultiDictionary* kStatesToCities;

static NSArray *kAdditionalCitiesInOregon;

static NSArray *kAllDictionaries;

- (id)init
{
    return [self initWithDepth:0 itemsProducer:^NSArray *(void) { return [kContinentsToCountries allKeys]; }];
}

- (id)initWithDepth:(NSUInteger)depth itemsProducer:(NSArray *(^)(void))itemsProducer
{
    if (self = [super init])
    {
        _depth = depth;
        _isLeaf = NO;
        _itemsProducer = itemsProducer;
    }
    return self;
}

- (NSUInteger)count
{
    return [_itemsProducer() count];
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    NSArray *orgItems = [_itemsProducer() subarrayWithRange:range];
    if (self.isLeaf)
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (NSString *item in orgItems)
        {
            [items addObject:[NSString stringWithFormat:@"%@-%i", item, arc4random_uniform(100)]];
        }
        return items;
    }
    else
    {
        return orgItems;
    }

}

- (NSString *)title
{
    return @"Continents";
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerSelection *)context 
                                       previousSelections:(NSArray *)previousSelections
{
    if (self.depth <= [kAllDictionaries count] - 1)
    {
        MultiDictionary *currentDict = [kAllDictionaries objectAtIndex:self.depth];
        SampleCityDataSource *ds = [[SampleCityDataSource alloc] initWithDepth:self.depth+1 itemsProducer:^NSArray *(void) {
            return [[currentDict objectsForKey:context.selectedItem] allObjects];
        }];
        ds.isLeaf = self.depth == [kAllDictionaries count] - 1;
        return ds;
    }
    return nil;
}

+ (void)addContinent:(NSString *)con country:(NSString *)cou region:(NSString *)r state:(NSString *)s cities:(NSArray *)c
{
    [kContinentsToCountries setObject:cou forKey:con];
    [kCountriesToRegions setObject:r forKey:cou];
    [kRegionsToStates setObject:s forKey:r];
    for (NSString *city in c)
    {
        [kStatesToCities setObject:city forKey:s];
    }
}

+ (NSString *)addCityToOregon
{
    static NSUInteger cityIndex = 0;
    NSString *city = [kAdditionalCitiesInOregon objectAtIndex:cityIndex];
    [kStatesToCities setObject:city forKey:@"Oregon"];
    cityIndex = (cityIndex + 1) % [kAdditionalCitiesInOregon count];
    return city;
}

+ (NSString *)removeCityFromOregon
{
    NSSet *cities = [kStatesToCities objectsForKey:@"Oregon"];
    if ([cities count] == 0)
    {
        return nil;
    }
    NSString *city = [cities anyObject];
    [kStatesToCities removeValue:city];
    return city;
}

+ (void)initialize
{
    kContinentsToCountries = [[MultiDictionary alloc] init];
    kCountriesToRegions = [[MultiDictionary alloc] init];
    kRegionsToStates = [[MultiDictionary alloc] init];
    kStatesToCities = [[MultiDictionary alloc] init];
    
    kAllDictionaries = @[kContinentsToCountries, kCountriesToRegions, kRegionsToStates, kStatesToCities];
    
    [self addContinent:@"America" 
               country:@"USA" 
                region:@"Pacific Northwest" 
                 state:@"Oregon" 
                  cities:@[@"Portland", @"Salem", @"Eugene", @"Bend", @"Ashland"]];
    
    [self addContinent:@"America" 
               country:@"USA" 
                region:@"Pacific Northwest" 
                 state:@"Washington" 
                cities:@[@"Seattle", @"Kirkland", @"Bellevue", @"Olympia"]];
    
    [self addContinent:@"Europe" 
               country:@"Spain" 
                region:@"Andalusia" 
                 state:@"Cadiz" 
                cities:@[@"Barbate", @"Conil de la Frontera", @"Medina Sidonia"]];
    
    [self addContinent:@"Europe" 
               country:@"Spain" 
                region:@"Catalonia" 
                 state:@"Tarragona" 
                cities:@[@"Reus", @"Salou", @"Tortosa", @"Valls"]];
    
    kAdditionalCitiesInOregon = @[@"Springfield", @"Medford", @"Corvallis"];
}

@end
