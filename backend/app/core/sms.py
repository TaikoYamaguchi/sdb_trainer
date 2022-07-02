import os
from twilio.rest import Client


# Find your Account SID and Auth Token at twilio.com/console
# and set the environment variables. See http://twil.io/secure
def send_sms_find_user(phone_number ):
    account_sid = 'ACe5029559094a7c0ad528fb87a041e7ff'
    auth_token = 'f2635d941f6b1e63dbe2183023743215'
    client = Client(account_sid, auth_token)
    verify = client.verify.services('VA0ab788570edd218112ae98e1cc0ef412')

    verify.verifications.create(
                         to='+82'+phone_number, channel='sms'
                     )

def verification_user(phone_number, verifyCode ):
    account_sid = 'ACe5029559094a7c0ad528fb87a041e7ff'
    auth_token = 'f2635d941f6b1e63dbe2183023743215'
    try :
        client = Client(account_sid, auth_token)
        verify = client.verify.services('VA0ab788570edd218112ae98e1cc0ef412')
        result = verify.verification_checks.create(to='+82'+phone_number, code = verifyCode)
        print(result.status)
        return result.status
    except ValueError as m:
        print (m)
        return m
    
