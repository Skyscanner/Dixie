//
// Dixie
// Copyright 2015 Skyscanner Limited
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.

#import "WeatherViewController.h"

@implementation WeatherViewController {
    CLLocationManager *locationManager;
    WeatherModel *weather;
    
    CGFloat lon;
    CGFloat lat;
    
    Dixie *myDixie;
    DixieProfileEntry *previousEntry;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    weather = [[WeatherModel alloc] init];
    
    // Get the location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    lon = locationManager.location.coordinate.longitude;
    lat = locationManager.location.coordinate.latitude;

    // Display the location on the view
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", lon];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", lat];
    
    // Init Dixie
    myDixie = [Dixie new];
}

- (void) viewDidDisappear:(BOOL)animated {
    
    // Revert Dixie when change a Tab - next time it will start with the original state
    myDixie.RevertIt(previousEntry);
}

- (IBAction)updateWeather:(id)sender
{
    // Get weather from the model
    [weather getCurrentWeatherWithLongitude:lon andLatitude:lat andCallback:^(WeatherModel *response) {
        
        // Display city and temperature to the view
        self.currentTempLabel.text = [NSString stringWithFormat:@"%@ %.1lf °C", response.city,  response.tempCurrent];
        
    }];
    
}

- (IBAction)dixieChangeResponse:(id)sender
{
    // Create a Dixie Block provider which will contain the new implementation
    DixieBlockChaosProvider *getProvider = [DixieBlockChaosProvider block:^(DixieBaseChaosProvider *chaosProvider, id victim, DixieCallEnvironment *environment) {
        
        // Get all the method arguments
        NSMutableArray* myArguments = [environment.arguments mutableCopy];
        
        // Create the mocked data
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] init];
        NSString *mockCity = @"Sin City";
        NSString *mockTemperatureK = @"324.792";
        NSDictionary *responseObject =
        @{
            @"base": @"cmc stations",
            @"clouds": @{
                    @"all": @92
            },
            @"cod": @200,
            @"coord": @{
                    @"lat": @"37.33",
                    @"lon": @"-122.03",
            },
            @"dt": @1432213431,
            @"id": @5341145,
            @"main": @{
                    @"grnd_level": @"1015.29",
                    @"humidity": @100,
                    @"pressure": @"1015.29",
                    @"sea_level": @"1027.32",
                    @"temp": mockTemperatureK,
                    @"temp_max": @"284.792",
                    @"temp_min": @"284.792"
            },
            @"name": mockCity,
            @"rain": @{
                    @"3h": @"0.41125",
            },
            @"sys": @{
                    @"country": @"US",
                    @"message": @"0.0102",
                    @"sunrise": @1432212857,
                    @"sunset": @1432264512,
            },
            @"weather": @[
                @{
                    @"description": @"light rain",
                    @"icon": @"10d",
                    @"id": @500,
                    @"main": @"Rain"
                }
            ],
            @"wind": @{
                    @"deg": @"284.001",
                    @"speed": @"1.46"
            }
        };
        
        // Get the 3rd parameter of the "GET:parameters:success:failure:" method, the success block
        void(^block)(id,...) = [myArguments objectAtIndex:2];
        
        // Call the success block
        block(operation, responseObject);
        
        // Don't forward the chaos to the original Implementation, because I don't want to send out the request to network
    }];
    
    // Create the Dixie entry
    DixieProfileEntry *getEntry = [DixieProfileEntry entry:[AFHTTPRequestOperationManager class] selector:@selector(GET:parameters:success:failure:) chaosProvider:getProvider];
    
    // Revert the previously set entry
    if (previousEntry != nil) {
        myDixie.RevertIt(previousEntry);
    }
    
    // Save the previous entry - to be able to revert it
    previousEntry = getEntry;
    
    // Set Profile and Apply it
    myDixie.Profile(getEntry).Apply();
}

- (IBAction)dixieRevertMock:(id)sender
{
    myDixie.RevertIt(previousEntry);
}

@end