package com.rest;

import org.testng.annotations.Test;
import org.testng.annotations.BeforeClass;

import io.restassured.RestAssured;
import io.restassured.specification.*;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.filter.log.LogDetail;
import io.restassured.http.*;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;

import static io.restassured.RestAssured.*;
import static io.restassured.matcher.RestAssuredMatchers.*;
import static org.hamcrest.Matchers.*;
import static org.hamcrest.MatcherAssert.assertThat;

import java.io.File;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class PostmanWorkspaceAddUpdate {

	@BeforeClass
	public void beforeClass() {
		RequestSpecBuilder requestSpecBuilder = new RequestSpecBuilder()
				.setBaseUri("https://api.postman.com")
				.addHeader("X-Api-Key", "PMAK-REDACTED-REDACTED")
				.setContentType(ContentType.JSON)
				.log(LogDetail.ALL);
		RestAssured.requestSpecification = requestSpecBuilder.build();		
		
		ResponseSpecBuilder responseSpecBuilder = new ResponseSpecBuilder()
				.expectStatusCode(200)
				.expectContentType(ContentType.JSON)
				.log(LogDetail.ALL);
		RestAssured.responseSpecification = responseSpecBuilder.build();		
	}

	@Test
	public void validate_put_request_bdd_style() {
		//*************************************
		//This test first creates a new workspace then updates the name via PUT using returned id
		//*************************************
//		String payload = "{\n"
//				+ "    \"workspace\": {\n"
//				+ "    \"name\": \"Udemy-Training-DELETE-ME3\",\n"
//				+ "    \"type\": \"personal\",\n"
//				+ "    \"description\": \"Workspace created through RestAssured\"\n"
//				+ "    }\n"
//				+ "}";
		File fileCreate = new File ("src/main/resources/CreateWorkspacePayload1.json");
		System.out.println("*********** NEW TEST *****************");
		Response response = given()
				.body(fileCreate)
			.when()
				.post("/workspaces")
			.then()
				.assertThat().body("workspace.name", equalTo("Udemy-Training-DELETE-ME-Created"), "workspace.id", matchesPattern("^[a-z0-9-]{36}$"))
				.extract().response();
		String workspaceId = response.<String>path("workspace.id");
		System.out.println("New workspace ID = " + workspaceId);
		
		//*************************************
		//Use workspaceId from above POST request to make PUT update to workspace then validate
		//*************************************
//		String payloadUpdated = "{\n"
//				+ "    \"workspace\": {\n"
//				+ "    \"name\": \"Udemy-Training-DELETE-ME3-Updated\",\n"
//				+ "    \"type\": \"personal\",\n"
//				+ "    \"description\": \"Workspace updated through RestAssured\"\n"
//				+ "    }\n"
//				+ "}";
		File fileUpdate = new File ("src/main/resources/UpdateWorkspacePayload.json");
		Response responseUpdated = given()
				.body(fileUpdate)
				.pathParam("workspaceId", workspaceId)
			.when()
				.put("/workspaces/{workspaceId}")
			.then()
				.assertThat().body("workspace.name", equalTo("Udemy-Training-DELETE-ME-Updated"),
						"workspace.id", matchesPattern("^[a-z0-9-]{36}$"),
						"workspace.id", equalTo(workspaceId))
				.extract().response();
		String workspaceIdUpdated = responseUpdated.<String>path("workspace.id");
		System.out.println("Original workspace ID = " + workspaceId);
		System.out.println(" Updated workspace ID = " + workspaceIdUpdated);

		//*************************************
		//Use workspaceId from original POST request from above to DELETE the newly created/updated workspace
		//*************************************
		if (workspaceId.equals(workspaceIdUpdated)) {
			System.out.println("\n---------------------------------------------");
			System.out.println("DELETE in progress for workspace ID = " + workspaceId);
			System.out.println("---------------------------------------------\n");
			Response responseDeleted = given()
					.pathParam("workspaceId", workspaceId)
				.when()
					.delete("/workspaces/{workspaceId}")
				.then()
					.assertThat().body("workspace.id", matchesPattern("^[a-z0-9-]{36}$"),
							"workspace.id", equalTo(workspaceId))
					.extract().response();
			String workspaceIdDeleted = responseDeleted.<String>path("workspace.id");
			System.out.println("Original workspace ID = " + workspaceId);
			System.out.println(" Deleted workspace ID = " + workspaceIdDeleted);
				
		}	else {
			System.out.println("\n---------------------------------------------");
			System.out.println("THE ORIGINAL ID DOES NOT MATCH THE UPDATED ID");
			System.out.println("---------------------------------------------\n");
		}
		
		System.out.println("*********** TEST END *****************\n");
	}	
	
//	@Test
//	public void validate_put_request_nonbdd_style() {
//		//This test first creates a new workspace then updates the name via PUT using returned id
//		String payload = "{\n"
//				+ "    \"workspace\": {\n"
//				+ "    \"name\": \"Udemy-Training-DELETE-ME4\",\n"
//				+ "    \"type\": \"personal\",\n"
//				+ "    \"description\": \"Workspace created through RestAssured\"\n"
//				+ "    }\n"
//				+ "}";
//		System.out.println("*********** NEW TEST *****************");
//		Response response = with()
//				.body(payload)
//				.post("/workspaces");
//		assertThat(response.<String>path("workspace.name"), equalTo("Udemy-Training-DELETE-ME4"));
//		assertThat(response.<String>path("workspace.id"), matchesPattern("^[a-z0-9-]{36}$"));
//		assertThat(response.<String>path("workspace.id"), equalTo(workspaceId));
//		System.out.println("*********** TEST END *****************\n");
//	}

	@Test
	public void json_hashmap_request_bdd_style() {
		//*************************************
		//This test first creates a new workspace then updates the name via PUT using returned id
		//*************************************
		HashMap<String, Object> mainObject = new HashMap<String, Object>();
		HashMap<String, String> nestedObject = new HashMap<String, String>();
		
		nestedObject.put("name", "Udemy-Training-DELETE-ME-Created");
		nestedObject.put("type", "personal");
		nestedObject.put("description", "Workspace created through REST-Assured HashMap");
		mainObject.put("workspace", nestedObject);
		
		System.out.println("*********** NEW TEST *****************");
		Response response = given()
				.body(mainObject)
			.when()
				.post("/workspaces")
			.then()
				.assertThat().body("workspace.name", equalTo("Udemy-Training-DELETE-ME-Created"), "workspace.id", matchesPattern("^[a-z0-9-]{36}$"))
				.extract().response();
		String workspaceId = response.<String>path("workspace.id");
		System.out.println("New workspace ID = " + workspaceId);
		
		//*************************************
		//Use workspaceId from above POST request to make PUT update to workspace then validate
		//*************************************
		HashMap<String, Object> mainObjectUpdated = new HashMap<String, Object>();
		HashMap<String, String> nestedObjectUpdated = new HashMap<String, String>();
		
		nestedObjectUpdated.put("name", "Udemy-Training-DELETE-ME-Updated");
		nestedObjectUpdated.put("type", "personal");
		nestedObjectUpdated.put("description", "Workspace updated through REST-Assured HashMap");
		mainObjectUpdated.put("workspace", nestedObjectUpdated);
		
		Response responseUpdated = given()
				.body(mainObjectUpdated)
				.pathParam("workspaceId", workspaceId)
			.when()
				.put("/workspaces/{workspaceId}")
			.then()
				.assertThat().body("workspace.name", equalTo("Udemy-Training-DELETE-ME-Updated"),
						"workspace.id", matchesPattern("^[a-z0-9-]{36}$"),
						"workspace.id", equalTo(workspaceId))
				.extract().response();
		String workspaceIdUpdated = responseUpdated.<String>path("workspace.id");
		System.out.println("Original workspace ID = " + workspaceId);
		System.out.println(" Updated workspace ID = " + workspaceIdUpdated);

		//*************************************
		//Use workspaceId from original POST request from above to DELETE the newly created/updated workspace
		//*************************************
		if (workspaceId.equals(workspaceIdUpdated)) {
			System.out.println("\n---------------------------------------------");
			System.out.println("DELETE in progress for workspace ID = " + workspaceId);
			System.out.println("---------------------------------------------\n");
			Response responseDeleted = given()
					.pathParam("workspaceId", workspaceId)
				.when()
					.delete("/workspaces/{workspaceId}")
				.then()
					.assertThat().body("workspace.id", matchesPattern("^[a-z0-9-]{36}$"),
							"workspace.id", equalTo(workspaceId))
					.extract().response();
			String workspaceIdDeleted = responseDeleted.<String>path("workspace.id");
			System.out.println("Original workspace ID = " + workspaceId);
			System.out.println(" Deleted workspace ID = " + workspaceIdDeleted);
				
		}	else {
			System.out.println("\n---------------------------------------------");
			System.out.println("THE ORIGINAL ID DOES NOT MATCH THE UPDATED ID");
			System.out.println("---------------------------------------------\n");
		}
		
		System.out.println("*********** TEST END *****************\n");
	}

	
	
}
