package com.rest;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeClass;

import io.restassured.RestAssured;
import io.restassured.specification.ResponseSpecification;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.config.EncoderConfig;
import io.restassured.filter.log.LogDetail;
import io.restassured.http.*;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;

import static io.restassured.RestAssured.*;
import static io.restassured.matcher.RestAssuredMatchers.*;
import static org.hamcrest.Matchers.*;
import static org.hamcrest.MatcherAssert.assertThat;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class MockServerComplexJsonArrayList {
	ResponseSpecification customResponseSpecification;

	@BeforeClass
	public void beforeClass() {
		//********************************
		//Using Postman Mock Server from REDACTED@gmail.com account to run these tests
		//********************************
		
		RequestSpecBuilder requestSpecBuilder = new RequestSpecBuilder()
				.setBaseUri("https://REDACTED-a3cc-4a3c-a186-REDACTED.mock.pstmn.io")
				.addHeader("x-mock-match-request-headers", "true")
				.setContentType(ContentType.JSON)
				.log(LogDetail.ALL);
		RestAssured.requestSpecification = requestSpecBuilder.build();		
		
		ResponseSpecBuilder responseSpecBuilder = new ResponseSpecBuilder()
				.expectStatusCode(200)
				.expectContentType(ContentType.JSON)
				.log(LogDetail.ALL);
		
		customResponseSpecification = responseSpecBuilder.build();		
	}

	@Test
	public void validate_post_request_payload_complex_json_array_as_list() {
		//*************************************
		//send request using JSON array list to mock server
		//*************************************
		
		//Define hashmap for json array list
		// --------------------------------------
		// batters HashMap
		// --------------------------------------
		List<Integer> idArrayList = new ArrayList<Integer>();
		idArrayList.add(5);
		idArrayList.add(9);

		HashMap<String, Object> batterHashMap2 = new HashMap<String, Object>();
		batterHashMap2.put("id", idArrayList);
		batterHashMap2.put("type", "Chocolate");
		
		HashMap<String, Object> batterHashMap1 = new HashMap<String, Object>();
		batterHashMap1.put("id", "1001");
		batterHashMap1.put("type", "Regular");
		
		ArrayList<HashMap<String, Object>> batterArrayList = new ArrayList<HashMap<String, Object>>();
		batterArrayList.add(batterHashMap1);
		batterArrayList.add(batterHashMap2);
		
		HashMap<String, List> battersHashMap = new HashMap<String, List>();
		battersHashMap.put("batter", batterArrayList);

		// --------------------------------------
		// toppings HashMap
		// --------------------------------------
		ArrayList<String> typeArrayList = new ArrayList<String>();
		typeArrayList.add("test1");
		typeArrayList.add("test2");
		
		HashMap<String, Object> toppingHashMap2 = new HashMap<String, Object>();
		toppingHashMap2.put("id", "5002");
		toppingHashMap2.put("type", typeArrayList);
		
		HashMap<String, Object> toppingHashMap1 = new HashMap<String, Object>();
		toppingHashMap1.put("id", "5001");
		toppingHashMap1.put("type", "None");
		
		ArrayList<HashMap<String, Object>> toppingArrayList = new ArrayList<HashMap<String, Object>>();
		toppingArrayList.add(batterHashMap1);
		toppingArrayList.add(batterHashMap2);

		// --------------------------------------
		// Main JSON HashMap
		// --------------------------------------
		HashMap<String, Object> mainHashMap = new HashMap<String, Object>();
		mainHashMap.put("id", "0001");
		mainHashMap.put("type", "donut");
		mainHashMap.put("name", "cake");
		mainHashMap.put("ppu", 0.55);
		mainHashMap.put("batters", battersHashMap);
		mainHashMap.put("topping", toppingArrayList);
		
		System.out.println("*********** NEW TEST *****************");
		Response response = given()
				.body(mainHashMap)
			.when()
				.post("/postComplexJSON")
			.then()
				.spec(customResponseSpecification)
				.assertThat().body("msg", equalTo("Success - Complex JSON"))
				.extract().response();
		//String workspaceId = response.<String>path("workspace.id");
		//System.out.println("New workspace ID = " + workspaceId);
	}
	
}
