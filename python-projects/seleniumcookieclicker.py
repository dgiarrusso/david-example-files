import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.keys import Keys

driver = webdriver.Chrome()

driver.get("https://orteil.dashnet.org/experiments/cookie/")

element = WebDriverWait(driver, 10).until(lambda x: x.find_element(By.ID, "cookie"))
theCookie = driver.find_element(By.ID, "cookie")

BUY_INTERVAL = 10
TOTAL_RUN_TIME = 60*20
start_time = round(time.time())
timeout = start_time + BUY_INTERVAL


def buy_item(upgrade):
    driver.find_element(By.ID, 'buy'+upgrade[0]).click()


def check_money():
    money = int(driver.find_element(By.ID, "money").text)
    print(f"Money = {money}")
    return money


def check_cps():
    cps = float(driver.find_element(By.ID, "cps").text.split(':')[1].strip())
    print(f"CPS = {cps}")


def check_purchase():
    store_items = driver.find_elements(By.CSS_SELECTOR, "#store div b")
    store_items.pop()
    store = [item.text for item in store_items]
    upgrades = []
    for item in store_items:
        upgrades.append([
            item.text.split('-')[0].strip(),
            int((item.text.split('-')[1]).replace(',', ''))
        ])
    money = check_money()
    for n in reversed(range(len(upgrades))):
        if upgrades[n][1] < money:
            buy_item(upgrades[n])
            break


keep_clicking = True
###############################
# Main game loop
###############################
while keep_clicking:
    now = round(time.time())

    if now >= (start_time + TOTAL_RUN_TIME):
        check_cps()
        print(f"Thanks for playing!")
        keep_clicking = False

    if now <= timeout:
        theCookie.click()

    #Every 5 seconds check for buying items and rest timeout value
    if now >= timeout:
        check_purchase()
        check_cps()
        # Set next-purchase timeout for new checkpoint
        timeout += BUY_INTERVAL

driver.quit()