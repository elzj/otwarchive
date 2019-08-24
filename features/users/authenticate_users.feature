@users
@admin
Feature: User Authentication

  Scenario: Forgot password
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "User name or email:" with "sam"
      And I fill in "Password:" with "test"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records"
      And I should see "Forgot your password or user name?"
    When I follow "Reset password"
    Then I should see "Please tell us the user name or email address you used when you signed up for your Archive account"
    When I fill in "Email address or user name" with "sam"
      And I press "Reset Password"
    Then I should see "Check your email for instructions on how to reset your password."
      And 1 email should be delivered
      And the email should contain "sam"
      And the email should contain "someone has requested a password reset for your account"
      And the email should not contain "translation missing"

    # existing password should still work
    When I am on the homepage
      And I fill in "User name or email:" with "sam"
      And I fill in "Password:" with "secret"
      And I press "Log In"
    Then I should see "Hi, sam"

    # link from the email should not work when logged in
    When I follow "Change my password." in the email
    Then I should see "You are already signed in."
      And I should not see "Change My Password"

    # link from the email should work
    When I am logged out
      And I follow "Change my password." in the email
    Then I should see "Change My Password"

    # entering mismatched passwords should produce an error message
    When I fill in "New password" with "secret"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "We couldn't save this user because:"
      And I should see "Password confirmation doesn't match confirmation"

    # and I should be able to change the password
    When I fill in "New password" with "new<pass"
      And I fill in "Confirm new password" with "new<pass"
      And I press "Change Password"
    Then I should see "Your password has been changed successfully. You are now signed in."
      And I should see "Hi, sam"

    # password reset link should no longer work
    When I am logged out
      And I follow "Change my password." in the email
      And I fill in "New password" with "override"
      And I fill in "Confirm new password" with "override"
      And I press "Change Password"
    Then I should see "We couldn't save this user because:"
      And I should see "Reset password token is invalid"

    # old password should no longer work
    When I am logged out
      And I am on the homepage
      And I fill in "User name or email:" with "sam"
      And I fill in "Password:" with "secret"
      And I press "Log In"
    Then I should not see "Hi, sam"

    # new password should work
    When I am logged out
      And I am on the homepage
      And I fill in "User name or email:" with "sam"
      And I fill in "Password:" with "new<pass"
      And I press "Log In"
    Then I should see "Hi, sam"
      And I should see "You used a temporary password to log in."
      And I should see "Change My Password"

  Scenario: With expired password token
    Given I have no users
      And the following activated user exists
        | login | password |
        | sam   | password |
      And all emails have been delivered
    When I am on the login page
      And I follow "Reset password"
      And I fill in "reset_password_for" with "sam"
      And I press "Reset Password"
    Then 1 email should be delivered
    When I am logged out
      And the password reset token for "sam" is expired
    When I fill in "User name" with "sam"
      And I fill in "sam"'s temporary password
      And I press "Log In"
    Then I should see "The password you entered has expired."
      And I should not see "Hi, sam!"
      And I should see "Log In"

  Scenario: User is locked out
    Given I have no users
      And the following activated user exists
        | login | password |
        | sam   | password |
      And all emails have been delivered
      And the user "sam" has failed to log in 50 times
      When I am on the home page
        And I fill in "User name" with "sam"
        And I fill in "Password" with "badpassword"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should not be able to log back in even with correct password
      When I am on the home page
        And I fill in "User name" with "sam"
        And I fill in "Password" with "password"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should be able to log in with the correct password 5 minutes later
      When 5 minutes have passed
        And I am on the home page
        And I fill in "User name" with "sam"
        And I fill in "Password" with "password"
        And I press "Log In"
      Then I should see "Successfully logged in."
        And I should see "Hi, sam!"

    # password entered the second time should not work
    When I am logged out
      And I am on the homepage
      And I fill in "User name or email:" with "sam"
      And I fill in "Password:" with "override"
      And I press "Log In"
    Then I should not see "Hi, sam"

  Scenario: Forgot password, logging in with email address
    Given I have no users
      And the following activated user exists
        | login | email           | password |
        | sam   | sam@example.com | password |
      And all emails have been delivered
    When I am on the login page
      And I follow "Reset password"
      And I fill in "Email address or user name" with "sam@example.com"
      And I press "Reset Password"
    Then I should see "Check your email for instructions on how to reset your password."
      And 1 email should be delivered
    When I am logged out
      And I follow "Change my password." in the email
      And I fill in "New password" with "newpass"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "Your password has been changed successfully."
      And I should see "Hi, sam"

  Scenario: Forgot password, with expired password token
    Given I have no users
      And the following activated user exists
        | login | password |
        | sam   | password |
      And all emails have been delivered
    When I am on the login page
      And I follow "Reset password"
      And I fill in "Email address or user name" with "sam"
      And I press "Reset Password"
    Then I should see "Check your email for instructions on how to reset your password."
      And 1 email should be delivered
    When it is currently 2 weeks from now
      And I am logged out
      And I follow "Change my password." in the email
      And I fill in "New password" with "newpass"
      And I fill in "Confirm new password" with "newpass"
      And I press "Change Password"
    Then I should see "We couldn't save this user because:"
      And I should see "Reset password token has expired, please request a new one"
      And I should see "Log In"
      And I should not see "Your password has been changed"
      And I should not see "Hi, sam!"

  Scenario: User is locked out
    Given I have no users
      And the following activated user exists
        | login | password |
        | sam   | password |
      And all emails have been delivered
      And the user "sam" has failed to log in 50 times
      When I am on the home page
        And I fill in "User name or email:" with "sam"
        And I fill in "Password:" with "badpassword"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should not be able to log back in even with correct password
      When I am on the home page
        And I fill in "User name or email:" with "sam"
        And I fill in "Password:" with "password"
        And I press "Log In"
      Then I should see "Your account has been locked for 5 minutes"
        And I should not see "Hi, sam!"

      # User should be able to log in with the correct password 5 minutes later
      When it is currently 5 minutes from now
        And I am on the home page
        And I fill in "User name or email:" with "sam"
        And I fill in "Password:" with "password"
        And I press "Log In"
      Then I should see "Successfully logged in."
        And I should see "Hi, sam!"

  Scenario: Wrong username
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "User name or email:" with "sammy"
      And I fill in "Password:" with "test"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records. Please try again or reset your password. If you still can't log in, please visit Problems When Logging In for help."

  Scenario: Wrong password
    Given I have no users
      And the following activated user exists
      | login    | password |
      | sam      | secret   |
      And all emails have been delivered
    When I am on the home page
      And I fill in "User name or email:" with "sam"
      And I fill in "Password:" with "tester"
      And I press "Log In"
    Then I should see "The password or user name you entered doesn't match our records. Please try again or reset your password. If you still can't log in, please visit Problems When Logging In for help."

  Scenario: Logged out
    Given I have no users
     And a user exists with login: "sam"
    When I am on sam's user page
    Then I should see "Log In"
      And I should not see "Log Out"
      And I should not see "Preferences"

  Scenario: Login case (in)sensitivity
    Given the following activated user exists
      | login      | password |
      | TheMadUser | password1 |
    When I am on the home page
      And I fill in "User name or email:" with "themaduser"
      And I fill in "Password:" with "password1"
      And I press "Log In"
    Then I should see "Successfully logged in."
      And I should see "Hi, TheMadUser!"

  Scenario: Login with email
    Given the following activated user exists
      | login      | email                  | password |
      | TheMadUser | themaduser@example.com | password |
    When I am on the home page
      And I fill in "User name or email:" with "themaduser@example.com"
      And I fill in "Password:" with "password"
      And I press "Log In"
      Then I should see "Successfully logged in."
        And I should see "Hi, TheMadUser!"

  Scenario: Not using remember me gives a warning about length of session
    Given the following activated user exists
      | login   | password |
      | MadUser | password |
    When I am on the home page
      And I fill in "User name or email:" with "maduser"
      And I fill in "Password:" with "password"
      And I press "Log In"
    Then I should see "Successfully logged in."
      And I should see "You'll stay logged in for 2 weeks even if you close your browser"

  # TODO make this an actual test - it's been 4 years...
  Scenario Outline: Show or hide preferences link
    Given I have no users
      And the following activated users exist
      | login    | password |
      | sam      | secret   |
      | dean     | secret   |
    And I am logged in as "<login>" with password "secret"
    When I am on <user>'s user page
    Then I should <action>

    Examples:
      | login | user  | action                   |
      | sam   | sam   | not see "Log In"         |
      | sam   | sam   | see "Log Out"            |
      | sam   | sam   | see "Preferences" within "#dashboard"    |
      | sam   | dean  | see "Log Out"            |
      | sam   | dean  | not see "Preferences" within "#dashboard" |
      | sam   | dean  | not see "Log In"         |
