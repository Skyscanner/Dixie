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

#import "WeatherModel.h"

@implementation WeatherModel
{
    NSDictionary *weatherServiceResponse;
}

- (id)init
{
    self = [super init];
    weatherServiceResponse = @{};
    return self;
}

- (void)getCurrentWeatherWithLongitude:(CGFloat)lon andLatitude:(CGFloat)lat andCallback:(void (^)(WeatherModel *))callback
{
    // Create the request URL
    NSString *const BASE_URL_STRING = @"http://api.openweathermap.org/data/2.5/weather";
    NSString *weatherURLText = [NSString stringWithFormat:@"%@?lat=%lf&lon=%lf", BASE_URL_STRING, lat, lon];
    
    // Do the request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:weatherURLText parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Get and parse the response
        weatherServiceResponse = (NSDictionary *)responseObject;
        [self parseWeatherServiceResponse];
        callback(self);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // AFNetwork error
        NSLog(@"Error: %@", error);
        weatherServiceResponse = @{};
        
    }];
}

- (void)parseWeatherServiceResponse
{
    // Convert from Kelvin to Celsius
    _tempCurrent = [weatherServiceResponse[@"main"][@"temp"] doubleValue] - 273.15;
    _city = weatherServiceResponse[@"name"];
}

@end
