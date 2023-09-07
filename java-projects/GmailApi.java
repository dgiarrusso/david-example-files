package com.rest.google.oauth2;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.config.EncoderConfig;
import io.restassured.filter.log.LogDetail;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;
import io.restassured.specification.ResponseSpecification;

import static io.restassured.RestAssured.given;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Base64;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.oltu.oauth2.client.OAuthClient;
import org.apache.oltu.oauth2.client.URLConnectionClient;
import org.apache.oltu.oauth2.client.request.OAuthClientRequest;
import org.apache.oltu.oauth2.client.response.OAuthJSONAccessTokenResponse;
import org.apache.oltu.oauth2.common.OAuth;
import org.apache.oltu.oauth2.common.message.types.GrantType;
import org.json.JSONObject;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

import com.fasterxml.jackson.core.JsonProcessingException;

public class GmailApi {
	RequestSpecification requestSpecification;
	ResponseSpecification responseSpecification;
	String accessToken = getAccessToken();
	String bearerToken = "Bearer " + accessToken;
	String emailAddress = "REDACTED@gmail.com";
	String scope = "https://mail.google.com";
	
	////////////////////////////////////////////////////////////////////////////
	// Code block taken from StackOverflow page below
	// From: https://stackoverflow.com/questions/36214968/how-to-get-access-token-using-gmail-api
	// NOTE: Need to update the refresh_token parameter below to valid value in order to make this functional
	private String getAccessToken()	{
	    try
	    {
	        Map<String,Object> params = new LinkedHashMap<String, Object>();
	        params.put("grant_type","refresh_token");
	        params.put("client_id","REDACTED-REDACTED.apps.googleusercontent.com");
	        params.put("client_secret","GOCSPX-Sis_REDACTED");
	        params.put("refresh_token","1//REDACTED");

	        StringBuilder postData = new StringBuilder();
	        for(Map.Entry<String,Object> param : params.entrySet())
	        {
	            if(postData.length() != 0)
	            {
	                postData.append('&');
	            }
	            postData.append(URLEncoder.encode(param.getKey(),"UTF-8"));
	            postData.append('=');
	            postData.append(URLEncoder.encode(String.valueOf(param.getValue()),"UTF-8"));
	        }
	        byte[] postDataBytes = postData.toString().getBytes("UTF-8");

	        URL url = new URL("https://accounts.google.com/o/oauth2/token");
	        HttpURLConnection con = (HttpURLConnection)url.openConnection();
	        con.setDoOutput(true);
	        con.setUseCaches(false);
	        con.setRequestMethod("POST");
	        con.getOutputStream().write(postDataBytes);

	        BufferedReader  reader = new BufferedReader(new InputStreamReader(con.getInputStream()));
	        StringBuffer buffer = new StringBuffer();
	        for (String line = reader.readLine(); line != null; line = reader.readLine())
	        {
	            buffer.append(line);
	        }

	        JSONObject json = new JSONObject(buffer.toString());
	        String newAccessToken = json.getString("access_token");
	    	//System.out.println("Access Token = " + newAccessToken);
	        return newAccessToken;
	    }
	    catch (Exception ex)
	    {
	        ex.printStackTrace(); 
	    }
	    return null;
	}
	////////////////////////////////////////////////////////////////////////////

	            
	@BeforeClass
	public void beforeClass() {
		RequestSpecBuilder requestSpecBuilder = new RequestSpecBuilder()
				.setBaseUri("https://gmail.googleapis.com")
				.addHeader("Authorization", bearerToken)
				//.setBaseUri("https://oauth2.googleapis.com")
				//		.setConfig(config.encoderConfig(EncoderConfig.encoderConfig()
				//				.appendDefaultContentCharsetToContentTypeIfUndefined(false)))
						.setContentType(ContentType.JSON)
						.log(LogDetail.ALL);
		requestSpecification = requestSpecBuilder.build();		
		
		ResponseSpecBuilder responseSpecBuilder = new ResponseSpecBuilder()
				.expectStatusCode(200)
				.expectContentType(ContentType.JSON)
				.log(LogDetail.ALL);
		
		responseSpecification = responseSpecBuilder.build();		
	}
	
	
	@Test
	public void update_access_token_with_refresh_token() {
		System.out.println("********** REFRESH TOKEN *************");	
		accessToken = getAccessToken();
		bearerToken = "Bearer " + accessToken;
		System.out.println("New Access Token = " + accessToken);	
		System.out.println("New Bearer Token = " + bearerToken);	
	}
	
	@Test
	public void getUserProfile() {
		System.out.println("*********** NEW TEST *****************");
		//Update token (even though may already be updated)
		accessToken = getAccessToken();
		bearerToken = "Bearer " + accessToken;
		System.out.println("New Bearer Token = " + bearerToken);	

		given(requestSpecification)
			.basePath("/gmail/v1")
			.pathParam("userid", emailAddress)
		.when()
			.get("/users/{userid}/profile")
		.then().spec(responseSpecification);
			
	}

	@Test
	public void sendSimpleEmail() {
		System.out.println("*********** NEW TEST *****************");
		//Create initial string in format required by Gmail to send email message
		String message = "From: REDACTED@gmail.com\n" +
				"To: REDACTED@gmail.com\n" + 
				"Subject: Rest Assured Test Message 4/7/2023\n" + 
				"\n" +
				"Sending from Gmail API using Rest Assured script";
		//Encode above message into base64 byte string
		String base64UrlEncodedMessage = Base64.getUrlEncoder().encodeToString(message.getBytes());
		
		HashMap<String, String> payload = new HashMap<String, String>();
		payload.put("raw", base64UrlEncodedMessage);
		
		//Update token (even though may already be updated)
		accessToken = getAccessToken();
		bearerToken = "Bearer " + accessToken;
		System.out.println("New Bearer Token = " + bearerToken);	

		given(requestSpecification)
			.basePath("/gmail/v1")
			.pathParam("userid", emailAddress)
			.body(payload)
		.when()
			.post("/users/{userid}/messages/send")
		.then().spec(responseSpecification);
			
	}
	
}
