//
//  SPoT.h
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/25/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  General information that is used throughout the SPoT App

// ----> V Delete
#define RECENT_PHOTOS_NSUSERDEFAULTS_KEY @"SPoTApp.RecentPhotos"
#define MAX_PERSISTENT_PHOTOS 15
// ----> ^ Delete

#define RECENT_PHOTO_IMAGES_CACHES_DIRECTORY @"RecentPhotoImages"
#define DATABASE_NAME @"Stanford Photo Database"

// Assignment V, Hint 3 suggests using 3MB for 8 photos on the iPhone
#define IPHONE_CACHE_SIZE_LIMIT 3000000
// That makes 8 photos on the iPad equal 12MB
#define IPAD_CACHE_SIZE_LIMIT 12000000
