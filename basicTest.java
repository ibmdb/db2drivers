//package com.ibm.nosql.wireListener.test.db2UnitTests;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.MongoClientOptions;
import com.mongodb.ServerAddress;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoCollection;
import org.bson.Document;
import java.util.Arrays;
import com.mongodb.Block;

import com.mongodb.client.MongoCursor;
import static com.mongodb.client.model.Filters.*;
import com.mongodb.client.result.DeleteResult;
import static com.mongodb.client.model.Updates.*;
import com.mongodb.client.result.UpdateResult;
import java.util.ArrayList;
import java.util.List;

class basicTest {
    public static void main(String[] args) {
        System.out.println("Hello, World!"); 
		MongoClientOptions mongoClientOptions = MongoClientOptions.builder()
                                                .serverSelectionTimeout(500000)
                                                .build();
 		//MongoClient mongoClient = new MongoClient(new ServerAddress("localhost"), mongoClientOptions);
		//MongoClient mongoClient = new MongoClient("localhost", 27017);
		MongoClientURI connectionString = new MongoClientURI("mongodb://localhost:27017");
		MongoClient mongoClient = new MongoClient(connectionString);
		MongoDatabase database = mongoClient.getDatabase("test");
		MongoCollection<Document> collection = database.getCollection("book");
		Document doc = new Document("name", "MongoDB")
                .append("type", "database");
		collection.insertOne(doc);
		for (String name : database.listCollectionNames()) {
    		System.out.println("Collection Name = " + name);
		}
		System.out.println("Document Count = " + collection.countDocuments());
		MongoCursor<Document> cursor = collection.find().iterator();
		try {
		    while (cursor.hasNext()) {
		        System.out.println(cursor.next().toJson());
		    }
		} finally {
		    cursor.close();
		}
		
		DeleteResult deleteResult = collection.deleteMany(eq("name", "MongoDB"));
		System.out.println("Deleted doc count = " + deleteResult.getDeletedCount());
    }
}


