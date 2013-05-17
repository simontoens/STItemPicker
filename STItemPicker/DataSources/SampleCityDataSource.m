// @author Simon Toens 04/21/13

#import "MultiDictionary.h"
#import "SampleCityDataSource.h"

@interface SampleCityDataSource()
@property (nonatomic, assign) NSUInteger depth;
@property (nonatomic, strong) NSArray *items;
- (id)initWithDepth:(NSUInteger)depth items:(NSArray *)items;
@end

@implementation SampleCityDataSource

static MultiDictionary* kContinentsToCountries;
static MultiDictionary* kCountriesToRegions;
static MultiDictionary* kRegionsToStates;
static MultiDictionary* kStatesToCities;

static NSArray *kAllDictionaries;
static NSArray *kAllHeaders;

@synthesize depth = _depth;
@synthesize items = _items;

- (id)init
{
    return [self initWithDepth:0 items:[kContinentsToCountries allKeys]];
}

- (id)initWithDepth:(NSUInteger)depth items:(NSArray *)items
{
    if (self = [super init])
    {
        _depth = depth;
        _items = items;
    }
    return self;
}

- (NSUInteger)count
{
    return [self.items count];
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [self.items subarrayWithRange:range];
}

- (NSString *)title
{
    return [kAllHeaders objectAtIndex:self.depth];
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerContext *)context
{
    if (self.depth <= [kAllDictionaries count] - 1)
    {
        MultiDictionary *currentDict = [kAllDictionaries objectAtIndex:self.depth];
        return [[SampleCityDataSource alloc] initWithDepth:self.depth+1 items:[[currentDict objectsForKey:context.selectedItem] allObjects]];
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

+ (void)initialize 
{
    kContinentsToCountries = [[MultiDictionary alloc] init];
    kCountriesToRegions = [[MultiDictionary alloc] init];
    kRegionsToStates = [[MultiDictionary alloc] init];
    kStatesToCities = [[MultiDictionary alloc] init];
    
    kAllDictionaries = [NSArray arrayWithObjects:kContinentsToCountries, kCountriesToRegions, kRegionsToStates, kStatesToCities, nil];
    kAllHeaders = [NSArray arrayWithObjects:@"Continents", @"Countries", @"Regions", @"States", @"Cities", nil];
    
    [self addContinent:@"America" 
               country:@"USA" 
                region:@"Pacific Northwest" 
                 state:@"Oregon" 
                  cities:[NSArray arrayWithObjects:@"Portland", @"Salem", @"Eugene", @"Bend", @"Ashland", nil]];
    
    [self addContinent:@"America" 
               country:@"USA" 
                region:@"Pacific Northwest" 
                 state:@"Washington" 
                cities:[NSArray arrayWithObjects:@"Seattle", @"Kirkland", @"Bellevue", @"Olympia", nil]];
    
    [self addContinent:@"Europe" 
               country:@"Spain" 
                region:@"Andalusia" 
                 state:@"Cadiz" 
                cities:[NSArray arrayWithObjects:@"Barbate", @"Conil de la Frontera", @"Medina Sidonia", nil]];
    
    [self addContinent:@"Europe" 
               country:@"Spain" 
                region:@"Catalonia" 
                 state:@"Tarragona" 
                cities:[NSArray arrayWithObjects:@"Reus", @"Salou", @"Tortosa", @"Valls", nil]];
}

@end