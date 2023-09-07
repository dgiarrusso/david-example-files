from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import pprint

XPATH_EVENT_TIME = '//*[@id="content"]/div/section/div[2]/div[2]/div/ul/li[1]/time'
XPATH_EVENT_NAME = '//*[@id="content"]/div/section/div[2]/div[2]/div/ul/li[1]/a'

# Set browser to use
driver = webdriver.Chrome()

driver.get("https://www.python.org")

event_times = driver.find_elements(By.CSS_SELECTOR, ".event-widget time")
event_names = driver.find_elements(By.CSS_SELECTOR, ".event-widget li a")

events = {}

for n in range (len(event_times)):
    events[n] = {
        "time": event_times[n].text,
        "name": event_names[n].text,
    }
print(events)

driver.quit()
