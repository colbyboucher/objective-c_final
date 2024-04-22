//
//  main.m
//  objective-c_final
//
//  Created by Colby Boucher on 4/18/24.
//

#import <Foundation/Foundation.h>
#import "CarRental.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CarRental *system = [[CarRental alloc] init];
        while (true) {
            [system menu];
        }
    }
    return 0;
}
