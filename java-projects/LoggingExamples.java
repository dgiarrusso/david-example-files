package com.rest;

import org.testng.Assert;
import org.testng.annotations.Test;

import io.restassured.config.LogConfig;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;

import static io.restassured.RestAssured.*;
import static io.restassured.matcher.RestAssuredMatchers.*;
import static org.hamcrest.Matchers.*;

import java.util.HashSet;
import java.util.Set;

import static org.hamcrest.MatcherAssert.assertThat;


public class LoggingExamples {

	String url = "https://api.postman.com";
	String apiKey = "PMAK-REDACTED-REDACTED";

	@Test
	public void request_response_logging() {
		given().
			header("X-Api-Key", apiKey)
			.baseUri(url)
			.log().headers()
		.when()
			.get("/workspaces")
		.then()
			.log().ifError()
			//.log().body()
			.assertThat()
			.statusCode(200);
	}

	@Test
	public void request_response_failure_logging() {
		given().
			header("X-Api-Key", apiKey)
			.baseUri(url)
			.config(config.logConfig(LogConfig.logConfig().enableLoggingOfRequestAndResponseIfValidationFails()))
			//.log().ifValidationFails()
		.when()
			.get("/workspaces")
		.then()
			//.log().ifValidationFails()
			.assertThat()
			.statusCode(200);
	}

	@Test
	public void logs_blacklist_header() {
		given().
			header("X-Api-Key", apiKey)
			.baseUri(url)
			.config(config.logConfig(LogConfig.logConfig().blacklistHeader("X-Api-Key")))
			.log().all()
		.when()
			.get("/workspaces")
		.then()
			.assertThat()
			.statusCode(201);
	}

	
	@Test
	public void logs_blacklist_headers() {
		Set<String> headers = new HashSet<String>();
		headers.add("X-Api-Key");
		headers.add("Accept");
		
		given().
			header("X-Api-Key", apiKey)
			.baseUri(url)
			.config(config.logConfig(LogConfig.logConfig().blacklistHeaders(headers)))
			.log().all()
		.when()
			.get("/workspaces")
		.then()
			.assertThat()
			.statusCode(201);
	}

}
