/* Copyright (c) 2014 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GTLAnalyticsFilters.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   Google Analytics API (analytics/v3)
// Description:
//   View and manage your Google Analytics data
// Documentation:
//   https://developers.google.com/analytics/
// Classes:
//   GTLAnalyticsFilters (0 custom class methods, 8 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLAnalyticsFilter;

// ----------------------------------------------------------------------------
//
//   GTLAnalyticsFilters
//

// A filter collection lists filters created by users in an Analytics account.
// Each resource in the collection corresponds to a filter.

// This class supports NSFastEnumeration over its "items" property. It also
// supports -itemAtIndex: to retrieve individual objects from "items".

@interface GTLAnalyticsFilters : GTLCollectionObject

// A list of filters.
@property (retain) NSArray *items;  // of GTLAnalyticsFilter

// The maximum number of resources the response can contain, regardless of the
// actual number of resources returned. Its value ranges from 1 to 1,000 with a
// value of 1000 by default, or otherwise specified by the max-results query
// parameter.
@property (retain) NSNumber *itemsPerPage;  // intValue

// Collection type.
@property (copy) NSString *kind;

// Link to next page for this filter collection.
@property (copy) NSString *nextLink;

// Link to previous page for this filter collection.
@property (copy) NSString *previousLink;

// The starting index of the resources, which is 1 by default or otherwise
// specified by the start-index query parameter.
@property (retain) NSNumber *startIndex;  // intValue

// The total number of results for the query, regardless of the number of
// results in the response.
@property (retain) NSNumber *totalResults;  // intValue

// Email ID of the authenticated user
@property (copy) NSString *username;

@end
