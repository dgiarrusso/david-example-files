import base64
from bs4 import BeautifulSoup
import requests
import spotipy
from spotipy.oauth2 import SpotifyOAuth
import spotifycreds #Contains my Spotify App credentials
import pprint


#########################################
# Get list of top 100 songs from Billboard for specified date
# Default value
#########################################
date = input("Which year do you want to travel to? Type the date in this format YYYY-MM-DD\n"
             "or Press ENTER for default: ") or "2002-07-01"

response = requests.get("https://www.billboard.com/charts/hot-100/" + date)

soup = BeautifulSoup(response.text, 'html.parser')
song_names_spans = soup.select("li ul li h3")
song_names = [song.getText().strip() for song in song_names_spans]

# Couple of ways to print song list if needed for debug
pp = pprint.PrettyPrinter(indent=4)
#pp.pprint(song_names)
#print(f"Song Names = {song_names}")


#########################################
# Get auth token for Spotify account in 'spotifycreds.py'
# Make test call to retrieve recently played tracks
# This particular code is not required in order to create the playlist ... it's just a test
#########################################
scope = "user-read-recently-played"
sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=spotifycreds.client_id,
                                               client_secret=spotifycreds.client_secret,
                                               redirect_uri=spotifycreds.redirect_url, scope=scope))

results = sp.current_user_recently_played()
for idx, item in enumerate(results['items']):
    track = item['track']
    print(idx, track['artists'][0]['name'], " – ", track['name'])


#########################################
# Get song uri for each song in top 100 Billboard list
#########################################
song_uris = []
year = date.split("-")[0]
for song in song_names:
    result = sp.search(q=f"track:{song} year:{year}", type="track")
    print(result)
    try:
        uri = result["tracks"]["items"][0]["uri"]
        song_uris.append(uri)
    except IndexError:
        print(f"{song} doesn't exist in Spotify. Skipped.")

#pp.pprint(song_uris)


#########################################
# Create a playlist in Spotify for the date selected by user
#########################################
scope = "playlist-modify-private"
sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=spotifycreds.client_id,
                                               client_secret=spotifycreds.client_secret,
                                               redirect_uri=spotifycreds.redirect_url, scope=scope))
user_id = sp.current_user()["id"]

playlist = sp.user_playlist_create(user=user_id, name=f"{date} Billboard 100", public=False)
pp.pprint(playlist)

sp.playlist_add_items(playlist_id=playlist["id"], items=song_uris)

