'''
Author: David Giarrusso

Selenium version = 4.10.0 (seems there are some changes regarding path / options setup in recent releases)

Eclipse IDE = Version: 2023-06 (4.28.0)
Build id: 20230608-1333
OS: Windows 11, v.10.0, x86_64 / win32

Test URL = https://www.saucedemo.com/

Accepted usernames are:
standard_user | locked_out_user | problem_user | performance_glitch_user

Password for all users:
secret_sauce
'''

# Imports
from selenium import webdriver
import unittest
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import common

# Test: Successful Login  
class SauceDemo_Login_Test_Success(unittest.TestCase):
    def setUp(self):
        # Create new instance of the webdriver and configure
        self.option = webdriver.ChromeOptions()
        self.driver = webdriver.Chrome(options = self.option)
        # Demo web app - used for automation practice
        self.driver.get('https://www.saucedemo.com')
        
        # Wait for the page to load (sometimes page is slow and causes timeouts)
        self.driver.implicitly_wait(5)

    def tearDown(self):
        # Close browser
        self.driver.quit()

    # Find element(s) on page and assert condition
    def test_assert_condition(self):
        username = 'standard_user'
        password = 'secret_sauce'

        print("----------- Test case START -----------\n")
        print("TEST CASE: " + __class__.__name__)
        
        # Validate common Login page elements and get reference to each element needed in test
        testObject = self
        elementUserName = common.validateLoginElementUserName(testObject)
        elementPassword = common.validateLoginElementPassword(testObject)
        elementLoginButton = common.validateLoginElementLoginButton(testObject)
        
        # Enter username and password then click Login button
        elementUserName.send_keys(username)
        elementPassword.send_keys(password)
        elementLoginButton.click()

        # validate Logout button exists after successful login
        expectedUrl = "https://www.saucedemo.com/inventory.html"
        actualUrl = str(self.driver.current_url)
        print("-----> Validating actualUrl - current value = " + str(actualUrl))
        self.assertTrue(actualUrl == expectedUrl, "Login failed - reached unexpected url = " + actualUrl)
        
        print("\n-----------  Test case END  -----------")


class SauceDemo_Login_Test_Locked_Out_User(unittest.TestCase):
    def setUp(self):
        # Create new instance of the webdriver and configure
        self.option = webdriver.ChromeOptions()
        self.driver = webdriver.Chrome(options = self.option)
        # Demo web app - used for automation practice
        self.driver.get('https://www.saucedemo.com')

        # Wait for the page to load (sometimes page is slow and causes timeouts)
        self.driver.implicitly_wait(5)

    def tearDown(self):
        # Close browser
        self.driver.quit()

    # Find element(s) on page and assert condition
    def test_assert_condition(self):
        username = 'locked_out_user'
        password = 'secret_sauce'
        
        print("----------- Test case START -----------\n")
        print("TEST CASE: " + __class__.__name__)

        # Validate common Login page elements and get reference to each element needed in test
        testObject = self
        elementUserName = common.validateLoginElementUserName(testObject)
        elementPassword = common.validateLoginElementPassword(testObject)
        elementLoginButton = common.validateLoginElementLoginButton(testObject)
        
        # Enter username and password then click Login button
        elementUserName.send_keys(username)
        elementPassword.send_keys(password)
        elementLoginButton.click()

        # validate failed login url
        expectedUrl = "https://www.saucedemo.com/"
        actualUrl = str(self.driver.current_url)
        print("-----> Validating actualUrl - current value = " + str(actualUrl))
        self.assertTrue(actualUrl == expectedUrl, "Login failed - reached unexpected url = " + actualUrl)
        
        # validate button text for locked out account login attempt        
        expectedButtonText = "Epic sadface: Sorry, this user has been locked out."
        expectedButtonTextXpath = '//*[@id="login_button_container"]/div/form/div[3]/h3'
        elementButtonText = self.driver.find_element(By.XPATH, expectedButtonTextXpath)
        print("-----> Validating elementButtonText - expected value = " + expectedButtonText)
        self.assertTrue(elementButtonText.text == expectedButtonText, "Button text does not match - actual value = " + str(elementButtonText.text))
        
        print("\n-----------  Test case END  -----------")

if __name__ == '__main__':
    unittest.main()



