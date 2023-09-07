# Python price checker bot
# Product Title = Instant Pot Duo - 6qt Duo Plus
# Product url = https://www.amazon.com/dp/B01NBKTPTS?ref_=cm_sw_r_cp_ud_ct_FM9M699VKHTT47YD50Q6&th=1
import smtplib

import requests
import lxml
from bs4 import BeautifulSoup

############################################
# Get current price of item being watched in 'url' variable
############################################
# In order to use requests to get info from Amazon one needs to set the User-Agent and Accept-Language headers
# or the request is treated as a scraper and is denied access
url = "https://www.amazon.com/dp/B01NBKTPTS?ref_=cm_sw_r_cp_ud_ct_FM9M699VKHTT47YD50Q6&th=1"
header = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
    "Accept-Language": "en-US,en;q=0.9"
}

# Get initial page info
response = requests.get(url, headers=header)
soup = BeautifulSoup(response.content, "lxml")
#print(soup.prettify())


# Extract price as a float value using 'a-offscreen' class
current_price = float(soup.find(class_="a-offscreen").get_text().split("$")[1])
print(current_price)


# Check current vs target price and send email if threshold met
title = soup.find(id="productTitle").get_text().strip()
print(title)

BUY_PRICE = 200

myEmailAddress = '<REDACTED>'
myPassword = '<REDACTED>'

if current_price < BUY_PRICE:
    message = f"{title} is now {current_price}"

    with smtplib.SMTP('smtp.gmail.com', port=587) as connection:
        connection.starttls()
        result = connection.login(myEmailAddress, myPassword)
        connection.sendmail(
            from_addr=myEmailAddress,
            to_addrs=myEmailAddress,
            msg=f"Subject:Amazon Price Alert!\n\n{message}\n{url}".encode("utf-8")
        )
