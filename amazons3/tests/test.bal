//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/test;

string testAccessKeyId = config:getAsString("ACCESS_KEY_ID");
string testSecretAccessKey = config:getAsString("SECRET_ACCESS_KEY");
string testRegion = config:getAsString("REGION");
string testBucketName = config:getAsString("BUCKET_NAME");
string amazonHost = config:getAsString("AMAZON_HOST");

AmazonS3Configuration amazonS3Config = {
    accessKeyId: testAccessKeyId,
    secretAccessKey: testSecretAccessKey,
    region: testRegion,
    amazonHost: amazonHost
};

Client amazonS3Client = new(amazonS3Config);

@test:Config
function testGetBucketList() {
    log:printInfo("amazonS3ClientForGetBucketList -> getBucketList()");
    var response = amazonS3Client -> getBucketList();
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    } else {
        string bucketName = response[0].name;
        test:assertTrue(bucketName.length() > 0, msg = "Failed to call getBucketList()");
    }
}

@test:Config {
    dependsOn: ["testGetBucketList"]
}
function testCreateBucket() {
    log:printInfo("amazonS3Client -> createBucket()");
    var response = amazonS3Client -> createBucket(testBucketName);
    if (response is Status) {
        boolean bucketStatus = response.success;
        test:assertTrue(bucketStatus, msg = "Failed createBucket()");
    } else {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateBucket"]
}
function testCreateObject() {
    log:printInfo("amazonS3Client -> createObject()");
    var response = amazonS3Client -> createObject(testBucketName, "test.txt","Sample content");
    if (response is Status) {
        boolean objectStatus = response.success;
        test:assertTrue(objectStatus, msg = "Failed createObject()");
    } else {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateObject"]
}
function testGetObject() {
    log:printInfo("amazonS3Client -> getObject()");
    var response = amazonS3Client->getObject(testBucketName, "test.txt");
    if (response is S3Object) {
        string content = response.content;
        test:assertTrue(content.length() > 0, msg = "Failed to call getObject()");
    } else {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config {
    dependsOn: ["testGetObject"]
}
function testGetAllObjects() {
    log:printInfo("amazonS3Client -> getAllObjects()");
    var response = amazonS3Client -> getAllObjects(testBucketName);
    if (response is error) {
        test:assertFail(msg = <string>response.detail().message);
    } else {
        test:assertTrue(response.length() > 0, msg = "Failed to call getAllObjects()");
    }
}

@test:Config {
    dependsOn: ["testGetAllObjects"]
}
function testDeleteObject() {
    log:printInfo("amazonS3Client -> deleteObject()");
    var response = amazonS3Client -> deleteObject(testBucketName, "test.txt");
    if (response is Status) {
        boolean objectStatus = response.success;
        test:assertTrue(objectStatus, msg = "Failed deleteObject()");
    } else {
        test:assertFail(msg = <string>response.detail().message);
    }
}

@test:Config {
    dependsOn: ["testDeleteObject"]
}
function testDeleteBucket() {
    log:printInfo("amazonS3Client -> deleteBucket()");
    var response = amazonS3Client -> deleteBucket(testBucketName);
    if (response is Status) {
        boolean bucketStatus = response.success;
        test:assertTrue(bucketStatus, msg = "Failed deleteBucket()");
    } else {
        test:assertFail(msg = <string>response.detail().message);
    }
}
