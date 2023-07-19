'''
Common methods to be included in unit tests
'''

from selenium import webdriver
import unittest
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By


# Main Login page - User-name element
def validateLoginElementUserName(self):
    elementUserName = self.driver.find_element(By.ID, 'user-name')
    print("-----> Validating elementUserName exists - current value = " + str(elementUserName))
    self.assertTrue(elementUserName.is_displayed(), "user-name object not found on page")
    return elementUserName

# Main Login page - Password element
def validateLoginElementPassword(self):
    elementPassword = self.driver.find_element(By.ID, 'password')
    print("-----> Validating elementPassword exists - current value = " + str(elementPassword))
    self.assertTrue(elementPassword.is_displayed(), "password object not found on page")    
    return elementPassword

# Main Login page - Login Button element
def validateLoginElementLoginButton(self):
    elementLoginButton = self.driver.find_element(By.ID, 'login-button')
    print("-----> Validating elementLoginButton exists - current value = " + str(elementLoginButton))
    self.assertTrue(elementLoginButton.is_displayed(), "login-button object not found on page")
    return elementLoginButton

